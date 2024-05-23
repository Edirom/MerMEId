xquery version "1.0" encoding "UTF-8";
module namespace list = "http://kb.dk/this/getlist-sources";

import module namespace config = "https://github.com/edirom/mermeid/config" at "./config.xqm";

declare namespace fn = "http://www.w3.org/2005/xpath-functions";
declare namespace m = "http://www.music-encoding.org/ns/mei";
declare namespace ft = "http://exist-db.org/xquery/lucene";

declare function list:getlist($coll as xs:string, $query as xs:string) as node()*
{
    let $list :=
    if ($coll) then
        if ($query) then
            for $doc in collection($config:data-root)/m:mei
            [@meiversion=$config:meiversion]
            [m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type = "file_collection"][ft:query(., $coll)]]
            [string-length(string-join(m:meiHead/m:manifestationList/m:manifestation/m:titleStmt/m:title, "")) > 0]
            [ft:query(., $query)]
                order by $doc//m:workList/m:work[1]/m:contributor/m:persName[1]/string(),
                    $doc//m:workList/m:work[1]/m:title[1]/string()
            return
                $doc
        else
            for $doc in collection($config:data-root)/m:mei
            [@meiversion=$config:meiversion]
            [m:meiHead/m:fileDesc/m:seriesStmt/m:identifier[@type = "file_collection"][ft:query(., $coll)]]
            [string-length(string-join(m:meiHead/m:manifestationList/m:manifestation/m:titleStmt/m:title, "")) > 0]
                order by $doc//m:workList/m:work[1]/m:contributor/m:persName[1]/string(),
                    $doc//m:workList/m:work[1]/m:title[1]/string()
            return
                $doc
    else
        if ($query) then
            for $doc in collection($config:data-root)/m:mei
            [@meiversion=$config:meiversion]
            [ft:query(., $query)]
            [string-length(string-join(m:meiHead/m:manifestationList/m:manifestation/m:titleStmt/m:title, "")) > 0]
                order by $doc//m:workList/m:work[1]/m:contributor/m:persName[1]/string(),
                    $doc//m:workList/m:work[1]/m:title[1]/string()
            return
                $doc
        else
            for $doc in collection($config:data-root)/m:mei
            [@meiversion=$config:meiversion]
            [string-length(string-join(m:meiHead/m:manifestationList/m:manifestation/m:titleStmt/m:title, "")) > 0]
                order by $doc//m:workList/m:work[1]/m:contributor/m:persName[1]/string(),
                    $doc//m:workList/m:work[1]/m:title[1]/string()
            return
                $doc
    
    return
        $list

};


declare function list:get-reverse-links($target as xs:string) as node()*
{
    let $list :=
    for $doc in collection($config:data-root)/m:mei[@meiversion=$config:meiversion][m:meiHead//m:manifestation[@target = $target]]
    return
        $doc
    
    return
        $list

};
