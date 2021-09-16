xquery version "3.0";

import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
import module namespace util="http://exist-db.org/xquery/util";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
                
declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
    
else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>

else if (contains($exist:path, "/orbeon/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
        <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
        <set-attribute name="$exist:controller" value="{$exist:controller}"/>
        <set-attribute name="$exist:root" value="{$exist:root}"/>
        <set-attribute name="betterform.filter.ignoreResponseBody" value="true"/>
    </dispatch>

else if (contains($exist:path, "/resources/")) then 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
        <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
        <set-attribute name="$exist:controller" value="{$exist:controller}"/>
        <set-attribute name="$exist:root" value="{$exist:root}"/>
        <set-attribute name="betterform.filter.ignoreResponseBody" value="true"/>
    </dispatch>

(: pipe HTML files through our basic templating :)
else if (ends-with($exist:resource, ".html")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="no"/>
        <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
        <set-attribute name="$exist:controller" value="{$exist:controller}"/>
        <set-attribute name="$exist:root" value="{$exist:root}"/>
        <set-attribute name="betterform.filter.ignoreResponseBody" value="true"/>
        <view>
            <set-header name="Cache-Control" value="no-cache"/>
            <forward url="{$exist:controller}/modules/replace-vars.xq"/>
        </view>
    </dispatch>

(:
 : Login a user via AJAX. 
 : This will happen automagically (through the `login:set-user` function) by POSTing to this endpoint 
 :
 : returns a JSON object like {"isInMermeidGroup": false, "user": "admin"}
 :)
else if ($exist:resource = 'login') then
    let $loggedIn := login:set-user("org.exist.login", (), false())
    let $serializationParameters := ('method=text', 'media-type=application/json', 'encoding=utf-8')
    let $user := request:get-attribute("org.exist.login.user")
    let $isInMermeidGroup := sm:get-group-members('mermedit') = $user
    let $responseBody := 
        map { 
            'user': $user, 
            'isInMermeidGroup': $isInMermeidGroup 
        }
    return
        response:stream(
            serialize($responseBody, 
                <output:serialization-parameters>
                    <output:method>json</output:method>
                </output:serialization-parameters>
            ), 
            string-join($serializationParameters, ' ')
        )

else 
(: everything else is passed through
    diabling serverside betterform processing for eXist versions < v5.0.0
:)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="no"/>
        <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
        <set-attribute name="$exist:controller" value="{$exist:controller}"/>
        <set-attribute name="$exist:root" value="{$exist:root}"/>
        <set-attribute name="betterform.filter.ignoreResponseBody" value="true"/>
    </dispatch>
