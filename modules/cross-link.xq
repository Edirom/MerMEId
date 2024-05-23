xquery version "1.0" encoding "UTF-8";

(: Search the mei document store and return the data as an atom feed :)

import module namespace source_list="http://kb.dk/this/getlist-sources" at "main_loop_sources.xqm";
import module namespace loop="http://kb.dk/this/getlist" at "main_loop.xqm";
import module namespace config="https://github.com/edirom/mermeid/config" at "config.xqm";

declare default element namespace "http://www.kb.dk/dcm";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace app="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace opensearch="http://a9.com/-/spec/opensearch/1.1/";

declare option exist:serialize "method=xml media-type=text/xml"; 
declare variable $coll     := request:get-parameter("subject",  "");
declare variable $query    := request:get-parameter("query",    "");

declare variable $document := request:get-parameter("document", "");

declare variable $works    := request:get-parameter("get", "");

declare variable $page     := 
                 request:get-parameter("page","1")          cast as xs:integer;
declare variable $number   :=
                 request:get-parameter("itemsPerPage","20") cast as xs:integer;
declare variable $target   := 
                 request:get-parameter("target","")         cast as xs:string;

declare variable $from     := ($page - 1) * $number + 1;
declare variable $to       :=  $from      + $number - 1;



declare function app:getlist ($database as xs:string, $coll as xs:string, $query as xs:string) as node()* 
  {
    let $sortby         := session:get-attribute("sortby")
    let $sort0          := substring-before($sortby,",")
    let $sort1          := substring-after($sortby,",")

    let $list   := 
        if($coll) then 
        	if($query) then
                  for $doc in collection($database)/m:mei
                  [@meiversion=$config:meiversion]
                  [ft:query(.,$query) and m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[ft:query(.,$coll)]] 
        	  order by loop:sort-key ($coll,$doc,$sort0),loop:sort-key($coll,$doc,$sort1)
        	  return $doc 
        	else
        	  for $doc in collection($database)/m:mei
        	  [@meiversion=$config:meiversion]
        	  [m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[ft:query(.,$coll)]]
        	  order by loop:sort-key ($coll,$doc,$sort0),loop:sort-key($coll,$doc,$sort1)
        	  return $doc 
         else
           if($query) then
             for $doc in collection($database)/m:mei
             [@meiversion=$config:meiversion]
             [ft:query(.,$query)]
    	   order by loop:sort-key ("",$doc,$sort0),loop:sort-key("",$doc,$sort1)
    	 return $doc
           else
             for $doc in collection($database)/m:mei[@meiversion=$config:meiversion]
    	 order by loop:sort-key ("",$doc,$sort0),loop:sort-key("",$doc,$sort1)
	 return $doc
	      
	 return $list

};


declare function app:format-doc($doc  as node()) as node() {

    let $ref   := 
    <file>
        <series>{$doc/m:meiHead/m:fileDesc/m:seriesStmt/m:title/text()}</series>
        <seriesId>{$doc/m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"]/text()}</seriesId>
        <composer>{$doc/m:meiHead/m:workList/m:work/m:contributor/m:persName[@role='composer']/text()}</composer>
        <title>{$doc/m:meiHead/m:workList/m:work/m:title[text()][1]/text()}</title>
	<link 
	href="{util:document-name($doc)}" />

        <manifestations>
	    {
		for $manifestation in $doc/m:meiHead/m:manifestationList/m:manifestation
		return 
           <manifestation ref="{$manifestation/@xml:id}">
                    <title>{$manifestation/m:titleStmt/m:title[text()][1]/text()}</title>
		   </manifestation>
        }
        </manifestations>
    </file>
  return $ref
};

declare function app:opensearch-header($total as xs:integer,
                                       $start as xs:integer,
				       $items as xs:integer,
		                       $coll  as xs:string) as node()* {
  let $header := 
  (<opensearch:totalResults>{$total}</opensearch:totalResults>,
  <opensearch:startIndex>{$start}</opensearch:startIndex>,
  <opensearch:itemsPerPage>{$items}</opensearch:itemsPerPage>)

  return $header

};

<fileList>
{
  let $list := 
	if($works) then
          app:getlist($config:data-root,$coll,$query)
        else
	  if($target) then
	     source_list:get-reverse-links($target)
	  else
    	     source_list:getlist($coll,$query)



  let $intotal := fn:count($list/m:meiHead)

  return
    ( app:opensearch-header($intotal,
		$from,
		$number,
		$coll),
     <collections>
	{
          for $c in distinct-values(collection($config:data-root)/m:mei[@meiversion=$config:meiversion]//m:seriesStmt/m:identifier[@type="file_collection"][string()]/string())
             return
		<collection>{$c}</collection>
	}
     </collections>,
     for $doc at $count in $list[position() = ($from to $to)]
        return
	app:format-doc($doc)
     )
}
</fileList>
