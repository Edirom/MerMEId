xquery version "3.1";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
import module namespace config="https://github.com/edirom/mermeid/config" at "../modules/config.xqm";
import module namespace crud="https://github.com/edirom/mermeid/crud" at "../modules/crud.xqm";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

import module namespace console="http://exist-db.org/xquery/console";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

(:~
 : Wrapper function for outputting JSON
 :
 : @param $response-body the response body
 : @param $response-code the response status code
 :)
declare function output:stream-json($response-body, $response-code as xs:integer) as empty-sequence() {
    response:set-status-code($response-code),
    response:stream(
        serialize($response-body, 
            <output:serialization-parameters>
                <output:method>json</output:method>
            </output:serialization-parameters>
        ),
        'method=text media-type=application/json encoding=utf-8'
    )
};

(:~
 : Wrapper function for redirecting to the main page
 :)
declare function output:redirect-to-main-page() as element(exist:dispatch) {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{config:link-to-app('modules/list_files.xq')}"/>
    </dispatch>
};

(console:log('/data Controller'),
if (ends-with($exist:resource, ".xml")) then
    (console:log('/data Controller: XML data session: '||session:exists()),
    switch (request:get-method())
    case 'GET' return
    (console:log('/data Controller: GET: dispatching to transform.xq'),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
       <forward url="/{$exist:controller}/../modules/transform.xq" method="{request:get-method()}">
            <set-attribute name="transform.stylesheet" value="../filter/xsl/filter_get.xsl"/>
            <set-attribute name="transform.doc" value="{$config:data-root}{$exist:path}"/>
        </forward>
        <cache-control cache="no"/>
    </dispatch>)
    case 'PUT' return try {
    let $log := console:log('/data Controller: PUT: filter_put.xsl'),
(:        $logHeaders := console:log(for $headerName in request:get-header-names() return $headerName||': '||request:get-header($headerName)||'&#x0a;'),:)
(:        $logAttributes := console:log(for $attrName in request:attribute-names() return $attrName||': '||request:get-attribute($attrName)||'&#x0a;'),:)
(:        $logParameters := console:log(for $paramName in request:get-parameter-names() return $paramName||': '||request:get-parameter($paramName, '')||'&#x0a;'),:)
(:        $logCookieVals := console:log(for $cookieVal in request:get-cookie-names() return $cookieVal||': '||request:get-cookie-value($cookieVal)||'&#x0a;'),:)
        $filtered := transform:transform(request:get-data(), doc('../filter/xsl/filter_put.xsl'), <parameters>
                <param name="xslt.resources-endpoint" value="{config:get-property('exist_endpoint')}/resources"/>
                <param name="xslt.exist-endpoint-seen-from-orbeon" value="{$config:exist-endpoint-seen-from-orbeon}"/>
                <param name="xslt.orbeon-endpoint" value="{$config:orbeon-endpoint}"/>
                <param name="xslt.server-name" value="{config:get-property('exist_endpoint')}"/>
                <param name="xslt.document-root" value="/data/"/>
                <param name="exist:stop-on-warn" value="no"/>
                <param name="exist:stop-on-error" value="no"/>
                <param name="target" value="{$config:data-root}{$exist:path}"/>
</parameters>, <attributes></attributes>, "method=xml media-type=application/xml"),
        $saved := xmldb:store(string-join(($config:data-root,tokenize($exist:path, '/')[position() != last()]), '/'), $exist:resource, $filtered)
        return <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
           <forward url="/{$exist:controller}/../modules/transform.xq" method="{request:get-method()}">
                <set-attribute name="transform.stylesheet" value="../filter/xsl/filter_get.xsl"/>
                <set-attribute name="transform.doc" value="{$config:data-root}{$exist:path}"/>
            </forward>
            <cache-control cache="no"/>
        </dispatch>
    } catch * {
        response:set-status-code(500),
        <error>
            <code>{$err:code}</code>
            <value>{$err:value}</value>
            <description>{$err:description}</description>
        </error>
    }
    default return (response:set-status-code(405), <_/>)
    )
(:~
 : copy files endpoint 
 : For POST requests with Accept header 'application/json' the response 
 : of the crud operation (a map object) is returned as JSON, for all other
 : Accept headers the client is redirected to the main page (after the 
 : execution of the crud operation)   
 :)
else if($exist:path = '/copy' and request:get-method() eq 'POST') then
    let $source := request:get-parameter('source', '')
    let $target := request:get-parameter('target', util:uuid() || '.xml') (: generate a unique filename if none is provided :)
    let $title := request:get-parameter('title', ()) (: empty titles will get passed on and filled in later :)
    let $overwriteString := request:get-parameter('overwrite', 'false')
    let $overwrite := $overwriteString = ('1', 'yes', 'ja', 'y', 'on', 'true', 'true()') (: some string values that are considered boolean "true()" :)
    let $backend-response := crud:copy($source, $target, $overwrite, $title) 
    return 
        if(request:get-header('Accept') eq 'application/json')
        then output:stream-json(map:remove($backend-response, 'document-node'), $backend-response?code)
        else output:redirect-to-main-page()
(:~
 : delete files endpoint 
 : For POST requests with Accept header 'application/json' the response 
 : of the crud operation (an array) is returned as JSON, for all other
 : Accept headers the client is redirected to the main page (after the 
 : execution of the crud operation)   
 :)
else if($exist:path = '/delete' and request:get-method() eq 'POST') then 
    let $filename := request:get-parameter('filename', '')
    let $backend-response := crud:delete($filename)
    return 
        if(request:get-header('Accept') eq 'application/json')
        then output:stream-json($backend-response, $backend-response(1)?code)
        else output:redirect-to-main-page()
(:~
 : read files endpoint 
 : For GET requests with Accept header 'application/json' the response 
 : of the crud operation (a map object) is returned as JSON, for an
 : "application/xml" the raw XML document is returned
 :)
else if($exist:path = '/read' and request:get-method() eq 'GET') then 
    let $filename := request:get-parameter('filename', '')
    let $backend-response := crud:read($filename)
    return 
        if(request:get-header('Accept') eq 'application/json')
        then output:stream-json(map:remove($backend-response, 'document-node'), $backend-response?code)
        else if(contains(request:get-header('Accept'), 'application/xml'))
        then $backend-response?document-node
        else ()
(:~
 : rename files endpoint 
 : this simply chains a "copy" and a "delete" (if the first operation was successfull)
 : the returned object is a merge of the copy-response and the delete-response with a precedence for the former
 :)
else if($exist:path = '/rename' and request:get-method() eq 'POST') then 
    let $source := request:get-parameter('source', '')
    let $target := request:get-parameter('target', util:uuid() || '.xml') (: generate a unique filename if none is provided :)
    let $title := request:get-parameter('title', ()) (: empty titles will get passed on and filled in later :)
    let $overwriteString := request:get-parameter('overwrite', 'false')
    let $overwrite := $overwriteString = ('1', 'yes', 'ja', 'y', 'on', 'true', 'true()') (: some string values that are considered boolean "true()" :)
    let $backend-response-copy := crud:copy($source, $target, $overwrite, $title)
    let $backend-response-delete := 
        if($backend-response-copy instance of map(*) and $backend-response-copy?code = 200)
        then crud:delete($source)
        else ()
    return 
        if(request:get-header('Accept') eq 'application/json')
        then if($backend-response-delete instance of array(*)) 
            then output:stream-json(map:remove(map:merge(($backend-response-delete(1), $backend-response-copy)), 'document-node'), $backend-response-copy?code)
            else output:stream-json($backend-response-copy, $backend-response-copy?code)
        else output:redirect-to-main-page()
(:~
 : create files endpoint 
 :
 :)
else if($exist:path = '/create' and request:get-method() eq 'POST') then 
    let $templatepath := request:get-parameter('template', '../forms/model/new_file.xml')
    let $template :=
        if(doc-available($templatepath))
        then doc($templatepath)
        else ()
    let $filename := request:get-parameter('filename', util:uuid() || '.xml')
    let $store := 
        if($template and $filename) 
        then crud:create($template, $filename, false())
        else ()
    return
        if($store instance of map(*))
        then 
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <redirect url="{config:link-to-app('/forms/edit-work-case.xml') || '?doc=' || $filename}"/>
            </dispatch>
        else ()
    
else
(: everything else is passed through :)
   (console:log('/data Controller: passthrough'),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
        <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
        <set-attribute name="$exist:controller" value="{$exist:controller}"/>
        <set-attribute name="$exist:root" value="{$exist:root}"/>
    </dispatch>)
)
