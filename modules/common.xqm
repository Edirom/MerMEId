xquery version "3.1";

(:~
 : Common MerMEId XQuery functions
 :)
module namespace common="https://github.com/edirom/mermeid/common";

declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace map="http://www.w3.org/2005/xpath-functions/map";
declare namespace err="http://www.w3.org/2005/xqt-errors";
declare namespace util="http://exist-db.org/xquery/util";

import module namespace config="https://github.com/edirom/mermeid/config" at "config.xqm";
import module namespace functx="http://www.functx.com";

(:~
 : Function for outputting the "Year" information on the main list page
 : 
 : @param $doc the MEI document to extract the information from
 : @return the string representation of a period of time  
 :)
declare function common:display-date($doc as node()?) as xs:string {
    if($doc//mei:workList/mei:work/mei:creation/mei:date/(@notbefore|@notafter|@startdate|@enddate)!='') then
      concat(substring($doc//mei:workList/mei:work/mei:creation/mei:date/@notbefore,1,4),
      substring($doc//mei:workList/mei:work/mei:creation/mei:date/@startdate,1,4),
      '–',
      substring($doc//mei:workList/mei:work/mei:creation/mei:date/@enddate,1,4),
      substring($doc//mei:workList/mei:work/mei:creation/mei:date/@notafter,1,4))
    else if($doc//mei:workList/mei:work/mei:creation/mei:date/@isodate!='') then
      substring($doc//mei:workList/mei:work/mei:creation/mei:date[1]/@isodate,1,4)
    else if($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date/(@notbefore|@notafter|@startdate|@enddate)!='') then
      concat(substring($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date/@notbefore,1,4),
      substring($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date/@startdate,1,4),
      '–',
      substring($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date/@enddate,1,4),
      substring($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date/@notafter,1,4))
    else
      substring($doc//mei:workList/mei:work/mei:expressionList/mei:expression[mei:creation/mei:date][1]/mei:creation/mei:date[@isodate][1]/@isodate,1,4)
};

(:~
 : Function for outputting the "Collection" information on the main list page
 :
 : @param $doc the MEI document to extract the information from
 : @return the string representation of a collection 
 :)
declare function common:get-edition-and-number($doc as node()?) as xs:string {
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
      return concat($c, ' ', $n)
};

(:~
 : Get the composers of a work
 : This is used for outputting the "Composer" information on the main list page
 : as well as for crud:read()
 :
 : @param $doc the MEI document to extract the information from
 : @return a string-join of the composers, an empty sequence if none are given
 :)
declare function common:get-composers($doc as node()?) as xs:string? {
    $doc//mei:workList/mei:work/mei:contributor/mei:persName[@role='composer'] => string-join(', ')
};

(:~
 : Get the (main) title of a work
 : This is used for outputting the "Title" information on the main list page
 : as well as for crud:read()
 :
 : @param $doc the MEI document to extract the information from
 : @return the (main) title 
 :)
declare function common:get-title($doc as node()?) as xs:string {
    ($doc//mei:workList/mei:work/mei:title[text()])[1] => normalize-space()
};

(:~
 : Propose a new filename based on an existing one
 : This is simply done by adding "-copy" to the basenam of the file
 :
 : @param $filename the existing filename
 : @return a proposed filename 
 :)
declare function common:propose-filename($filename as xs:string) as xs:string {
    let $tokens := $filename => tokenize('\.')
    let $suffix := 
        if(count($tokens) gt 1) 
        then $tokens[last()]
        else 'xml'
    return
        if(count($tokens) eq 1) 
        then $tokens || '-copy.' || $suffix 
        else (subsequence($tokens, 1, count($tokens) -1) => string-join('.')) || '-copy.' || $suffix 
};

(:~
 : Add a change entry to the revisionDesc
 :
 : @param $document the input MEI document to add the change entry to 
 : @param $user the user identified with this change entry
 : @param $desc a description of the change
 :)
declare function common:add-change-entry-to-revisionDesc($document as document-node(), 
    $user as xs:string, $desc as xs:string) as empty-sequence() {
    let $change := 
        <change isodate="{current-dateTime()}" xml:id="{common:mermeid-id('change')}" 
            xmlns="http://www.music-encoding.org/ns/mei">
            <respStmt>
                <resp>{$user}</resp>
            </respStmt>
            <changeDesc xml:id="{common:mermeid-id('changeDesc')}">
                <p>{$desc}</p>
            </changeDesc>
        </change>
    return
        update insert $change into $document/mei:mei/mei:meiHead/mei:revisionDesc 
};

(:~
 : Generate an ID by prefixing an unique ID with an optional prefix
 :
 : @param $prefix an optional prefix for the ID
 : @return a unique ID 
 :)
declare function common:mermeid-id($prefix as xs:string?) as xs:string {
    $prefix || '_' || substring(util:uuid(),1,13)
};

(:~
 : Update target attributes
 :
 : @param $collection the collection of XML documents to look for and update references 
 : @param $old-identifier the old identifier of the XML document 
 : @param $new-identifier the new identifier of the XML document 
 : @param $dry-run "true()" will perform a dry run without changing the references
 : @return a map object with properties "old_identifier", "new_identifier", "dry_run", 
     "replacements", "changed_documents", and "message". "replacements" and "changed_documents"
     are their respective numbers and are negative (-1) if an error occured.   
 :)
declare function common:update-targets($collection as node()*, $old-identifier as xs:string, 
    $new-identifier as xs:string, $dry-run as xs:boolean) as map(*) {
    try {
        let $targets := $collection//@target[contains(., $old-identifier)]
        let $documents := $targets/root() ! document-uri(.)
        return (
            if($dry-run) then ()
            else (
                for $target in $targets
                let $replacement := replace($target, $old-identifier, $new-identifier)
                return 
                    update replace $target with $replacement
            ),
            map {
                'old_identifier': $old-identifier,
                'new_identifier': $new-identifier,
                'replacements': count($targets),
                'changed_documents': count($documents),
                'message': 'Success',
                'dry_run': $dry-run
            }
    )}
    catch * {
        map {
            'old_identifier': $old-identifier,
            'new_identifier': $new-identifier,
            'replacements': -1,
            'changed_documents': -1,
            'message': $err:description,
            'dry_run': $dry-run
        }
    }
};
