xquery version "3.1";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace mei="http://www.music-encoding.org/ns/mei";

import module namespace transform = "http://exist-db.org/xquery/transform";
import module namespace config="https://github.com/edirom/mermeid/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console";

let $inputDoc := (doc(request:get-attribute('transform.doc')), request:get-data())[1]
let $footer := config:get-property('footer') => config:replace-properties() => serialize(<output:serialization-parameters><output:method>xml</output:method></output:serialization-parameters>)

return 
    (: all non-MEI documents are passed through and those with the matching MEI version  :)
    if(not($inputDoc/mei:mei) or $inputDoc/mei:mei/@meiversion=$config:meiversion)  
    then transform:transform($inputDoc, doc(request:get-attribute('transform.stylesheet')), <parameters>
                <param name="xslt.resources-endpoint" value="{config:get-property('exist_endpoint')}/resources"/>
                <param name="xslt.exist-endpoint-seen-from-orbeon" value="{$config:exist-endpoint-seen-from-orbeon}"/>
                <param name="xslt.orbeon-endpoint" value="{$config:orbeon-endpoint}"/>
                <param name="xslt.server-name" value="{config:get-property('exist_endpoint')}"/>
                <param name="xslt.document-root" value="/data/"/>
                <param name="xslt.footer" value="{$footer}"/>
            </parameters>, <attributes></attributes>, "method=xml media-type=application/xml")
    (: issue error for non-matching MEI version :)
    else (
        response:set-status-code(404),
        <error>wrong MEI version. Must be {$config:meiversion}</error>
    )
