xquery version "3.1";

(:~
 : Common MerMEId XQuery functions
 :)
module namespace common="https://github.com/edirom/mermeid/common";

declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace map="http://www.w3.org/2005/xpath-functions/map";

import module namespace config="https://github.com/edirom/mermeid/config" at "config.xqm";

declare function common:display-date($doc as node()?) as xs:string {
    if($doc//mei:workList/mei:work/mei:creation/mei:date/(@notbefore|@notafter|@startdate|@enddate)!='') then
      concat(substring($doc//mei:workList/mei:work/mei:creation/mei:date/@notbefore,1,4),
      substring($doc//mei:workList/mei:work/mei:creation/mei:date/@startdate,1,4),
      '-',
      substring($doc//mei:workList/mei:work/mei:creation/mei:date/@enddate,1,4),
      substring($doc//mei:workList/mei:work/mei:creation/mei:date/@notafter,1,4))
    else if($doc//mei:workList/mei:work/mei:creation/mei:date/@isodate!='') then
      substring($doc//mei:workList/mei:work/mei:creation/mei:date[1]/@isodate,1,4)
    else if($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date/(@notbefore|@notafter|@startdate|@enddate)!='') then
      concat(substring($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date/@notbefore,1,4),
      substring($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date/@startdate,1,4),
      '-',
      substring($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date/@enddate,1,4),
      substring($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date/@notafter,1,4))
    else
      substring($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date[@isodate][1]/@isodate,1,4)
};

declare function common:get-edition-and-number($doc as node()?) as xs:string* {
      let $c := ($doc//mei:fileDesc/mei:seriesStmt/mei:identifier[@type="file_collection"])[1] => normalize-space()
      let $no := ($doc//mei:meiHead/mei:workList/mei:work/mei:identifier[normalize-space(@label)=$c])[1] => normalize-space()
      (: shorten very long identifiers (i.e. lists of numbers) :)
	  let $part1 := substring($no, 1, 11)
	  let $part2 := substring($no, 12)
      let $delimiter := substring(concat(translate($part2,'0123456789',''),' '),1,1)
      let $n := 
          if (string-length($no)>11) then 
            concat($part1,substring-before($part2,$delimiter),'...')
          else
            $no
      return ($c, $n)
};

declare function common:get-composers($doc as node()?) as xs:string? {
    $doc//mei:workList/mei:work/mei:contributor/mei:persName[@role='composer'] => string-join(', ')
};

declare function common:get-title($doc as node()?) as xs:string {
    ($doc//mei:workList/mei:work/mei:title[text()])[1] => normalize-space()
};
