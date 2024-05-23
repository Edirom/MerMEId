xquery version "1.0" encoding "UTF-8";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";
declare namespace xdb="http://exist-db.org/xquery/xmldb";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace local="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";

import module namespace login="http://kb.dk/this/login" at "../login.xqm";
import module namespace config="https://github.com/edirom/mermeid/config" at "../config.xqm";

declare option output:method "xhtml5";
declare option output:media-type "text/html";

declare variable $coll   := request:get-parameter("coll",    "") cast as xs:string;
declare variable $query  := request:get-parameter("query","") cast as xs:string;
declare variable $xsl    := xs:anyURI(request:get-parameter("xsl",config:link-to-app("/your-path-and-filename-here.xsl")));
declare variable $database := request:get-parameter("db",$config:data-root);

declare variable $local:sortby     := "null,work_number";

declare function local:getlist (
  $database        as xs:string,
  $coll            as xs:string,
  $query           as xs:string) as node()* 
  {
    let $list   := 
      if($coll) then 
	if($query) then
      for $doc in collection($database)/m:mei[@meiversion=$config:meiversion][m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll  and ft:query(.,$query)] 
	  return $doc 
	else
	  for $doc in collection($database)/m:mei[@meiversion=$config:meiversion][m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/string()=$coll] 
	  return $doc 
    else
	  if($query) then
        for $doc in collection($database)/m:mei[@meiversion=$config:meiversion][ft:query(.,$query)]
	    return $doc
    else
      for $doc in collection($database)/m:mei[@meiversion=$config:meiversion]
	  return $doc
    return $list
  };



declare function local:get-work-number($doc as node() ) as xs:string* {
  let $c := $doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"][1]/string()
  let $no := $doc//m:meiHead/m:workList/m:work[1]/m:identifier[@label=$c][1]/string()
  return ($c, $no)	
};


declare function local:transformed($doc as node() ) as node() {
    let $params := 
    <parameters>
       <param name="any_parameter" value=""/>
    </parameters>
    
    let $orig       := $doc//m:meiHead
    let $trans      := transform:transform($doc,$xsl,$params)//m:meiHead
    let $u :=  
      if(not(deep-equal($orig,$trans))) then
        update replace $orig with $trans
      else
        ""
    let $status :=
      if($u = "") then 
        <span>unchanged</span>
      else 
        <span style="color: red">transformed</span>
        
    return $status
};


(: Administrator: Uncomment the following line to allow users to perform batch transformations of data :)
(: let $log-in := login:function() :)

let $list := local:getlist($database, $coll, $query)


let $content := 
    if(false()) then (: set to disable by default. This needs some treatment per project :) 
        <div>
            <h1>Batch transform XML files in the database</h1> 
            <table cellpadding="2" cellspacing="0" border="0" style="width: auto;">
                <tr><th>Work no.&#160;</th><th>Title&#160;</th><th>File</th><th>Status</th></tr>
                {
                  for $doc in $list
                  let $html := 
                  <tr>
                     <td>{local:get-work-number($doc)} &#160;</td>
                     <td><a href="{config:link-to-app(concat("modules/present.xq?doc=",substring-after(document-uri(root($doc)),$database)))}" 
                        target="_blank" title="HTML preview">{$doc/m:meiHead/m:fileDesc/m:titleStmt/m:title[1]/string()}</a> &#160;</td>
                     <!-- This links is presumably broken … -->
                     <td><a href="{config:link-to-app(concat(replace(document-uri(root($doc)), $config:data-root,'/data/')))}" 
                        target="_blank" title="XML">{substring-after(document-uri(root($doc)),$database)}</a></td>
                     <td>{local:transformed($doc)}</td>
                  </tr>
                  return $html
                }   
            </table>
            <p>&#160;</p>
            <p>{count($list)} file(s) processed. </p>
        </div>
    else 
        <div>
            <h1>Batch transformation is currently disabled</h1>
            <p>Batch tranformation is disabled for security reasons on this server. <br/>
            Please ask your system administrator to enable transformation by editing the 
            file <kbd>/db/mermeid/tools/batch_transform.xq</kbd> in the eXist database.</p>
        </div>



return 
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Transformed documents</title>
    <link rel="stylesheet" type="text/css" href="../../resources/css/dcm.css"/>
    <link rel="stylesheet" type="text/css" href="../../resources/css/public_list_style.css"/>
    <link rel="styleSheet" type="text/css" href="../../resources/css/list_style.css"/>
    <link rel="styleSheet" type="text/css" href="../../resources/css/xform_style.css"/>
</head>
<body class="list_files">
    <div id="all">
        <div id="main">
            {$content}
        </div>
    </div>
</body>
</html>


