xquery version "3.0" encoding "UTF-8";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace config="https://github.com/edirom/mermeid/config" at "config.xqm";

declare option output:method "xhtml5";
declare option output:media-type "text/html";

let $content := request:get-data()
return
  config:replace-properties($content)
