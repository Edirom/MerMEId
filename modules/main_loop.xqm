xquery version "1.0" encoding "UTF-8";
module namespace loop="http://kb.dk/this/getlist";

import module namespace config="https://github.com/edirom/mermeid/config" at "./config.xqm";

declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace xdb="http://exist-db.org/xquery/xmldb";


declare function loop:pubstatus($doc as node()) as xs:boolean 
{
  let $published_only := session:get-attribute("published_only")
  let $dcmtime := xs:dateTime(xdb:last-modified($config:data-root, util:document-name($doc)))
  let $uri         := concat($config:data-public-root, "/", util:document-name($doc))

  let $status := 
    if( not($published_only) or $published_only eq '') then
      true()
    else
    if( doc-available($uri)) then
	  (:	let $public_hash := util:hash(doc($uri),'md5') :)
	  let $pubtime := xs:dateTime(xdb:last-modified($config:data-public-root, util:document-name($doc)))
	  return
	    (:if ($published_only eq 'pending' and $public_hash ne $dcm_hash) then :)
	    if ($published_only eq 'modified' and $pubtime le $dcmtime) then
	      true()
	    else 
	    if($published_only eq 'published') then
	      true()
	    else
	      false()
    else
	if($published_only eq 'unpublished') then
	  true()
	else 
	  false()

   return $status

};

declare function loop:work-number-for-sorting ($identifier as xs:string?) as xs:string {
      (: get anything that might be before the number :)
      let $prefix:= replace($identifier,'^([\D\s]*)(\d*)(.*?)$','$1')
      (: extract first number if any :)
      let $digits:= replace($identifier,'^([\D\s]*)(\d*)(.*?)$','$2')
      let $number:= if (string(number($digits)) != 'NaN')
        then number($digits)
        else 0 
      (: and any trailing stuff :)
      let $suffix:= replace($identifier,'^([\D\s]*)(\d*)(.*?)$','$3')
	return concat($prefix,format-number($number,"0000000000"),$suffix)
};

declare function loop:sort-key (
  $coll as xs:string?, 
  $doc as node(),
  $key as xs:string) as xs:string
{

  (: We don't want to waste time on looking up $collection if that parameter
  is fixed in the query :)
  let $collection:=
    if($coll) then
        $coll
    else if ($doc//m:seriesStmt/m:identifier[@type="file_collection" and string-length(.) > 0][1]/string()) then
        $doc//m:seriesStmt/m:identifier[@type="file_collection" and string-length(.) > 0][1]/string()
    else
        ""

  let $sort_key:=
    if($key eq "person") then
      replace(lower-case($doc/m:meiHead/m:workList/m:work/m:contributor/m:persName[1]/string()),"\\\\ ","")
    else if($key eq "title") then
      replace(lower-case($doc/m:meiHead/m:workList/m:work/m:title[1]/string()),"\\\\ ","")
    else if($key eq "date") then    
      let $dates := 
        if($doc/m:meiHead/m:workList/m:work/m:creation/m:date/(@notafter|@isodate|@notbefore|@startdate|@enddate)) then
          for $date in $doc/m:meiHead/m:workList/m:work/m:creation/m:date/(@notafter|@isodate|@notbefore|@startdate|@enddate)
	      return substring($date,1,4)
	    else 
	      (: if the composition does not have an overall dating, look for version datings instead and use the first dated version :)
          for $date in $doc/m:meiHead/m:workList/m:work/m:expressionList/m:expression/m:creation/m:date[@notafter|@isodate|@notbefore|@startdate|@enddate][1]/(@notafter|@isodate|@notbefore|@startdate|@enddate)
	      return substring($date,1,4)
      return 
      if(count($dates)>=1) then
        max($dates)
      else
        "0000"
    else if($key eq "work_number") then
       concat($collection," ",loop:work-number-for-sorting($doc/m:meiHead/m:workList/m:work[1]/m:identifier[@label=$collection][1]/string()) )
    else 
      ""

  return $sort_key

};

declare function loop:getlist ($database as xs:string) as node()* 
  {
    let $sortby         := session:get-attribute("sortby")
    let $sort0          := substring-before($sortby,",")
    let $sort1          := substring-after($sortby,",")
    let $coll           := session:get-attribute("coll")
    let $query          := session:get-attribute("query")

    let $list   := 
      if($coll) then 
	if($query) then
          for $doc in collection($database)/m:mei[
	    ft:query(.,$query)
	    and m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[ ft:query(.,$coll)]
	    and loop:pubstatus(.) ][@meiversion=$config:meiversion]
	  order by loop:sort-key ($coll,$doc,$sort0),loop:sort-key($coll,$doc,$sort1)
	  return $doc 
	else
	  for $doc in collection($database)/m:mei[
	    m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[ ft:query(.,$coll)]
	    and
	    loop:pubstatus(.) ][@meiversion=$config:meiversion]
	  order by loop:sort-key ($coll,$doc,$sort0),loop:sort-key($coll,$doc,$sort1)
	  return $doc 
     else
       if($query) then
         for $doc in collection($database)/m:mei[
	   ft:query(.,$query)
	   and loop:pubstatus(.) ][@meiversion=$config:meiversion]
	   order by loop:sort-key ("",$doc,$sort0),loop:sort-key("",$doc,$sort1)
	 return $doc
       else
         for $doc in collection($database)/m:mei[
           loop:pubstatus(.)][@meiversion=$config:meiversion]
	 order by loop:sort-key ("",$doc,$sort0),loop:sort-key("",$doc,$sort1)
	 return $doc
	      
	 return $list

};

