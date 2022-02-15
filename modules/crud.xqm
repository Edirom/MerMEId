xquery version "3.1";

(:~
 : Basic CRUD (Create, Read, Update, Delete) functions for the MerMEId data store
 :
 : All operations assume data is kept at $config:data-root and the file hierarchy is flat,
 : i.e. there are no subfolders
~:)
module namespace crud="https://github.com/edirom/mermeid/crud";

declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace map="http://www.w3.org/2005/xpath-functions/map";

import module namespace config="https://github.com/edirom/mermeid/config" at "config.xqm";

(:~
 : Delete files within the data directory
 :
 : @param $filenames the files to delete
 : @return a map object with the $filename as key and some return message as value
~:)
declare function crud:delete($filenames as xs:string*) as map(xs:string,xs:string) {
    map:merge(
        for $filename in $filenames
        return
            try {(
                xmldb:remove($config:data-root, $filename), 
                map:entry($filename, 'deleted successfully')
            )}
            catch * { 
                map:entry($filename, 'failed to delete: ' || string-join(($err:code, $err:description)))
            }
    )
};

(:~
 : Create a file within the data directory
 :
 : @param $node the XML document to store
 : @param $filename the filename for the new file
 : @return a map object with the $filename as key and some return message as value
~:)
declare function crud:create($node as node(), $filename as xs:string) as map(xs:string,xs:string) {
    map:entry(
        $filename,
        if(xmldb:store($config:data-root, $filename, $node))
        then 'created successfully'
        else 'failure'
    )
};

(:~
 : Copy a file within the data directory
 :
 : @param $source-filename the input filename to copy
 : @param $target-filename the output filename to copy to
 : @param $overwrite whether an existent target file may be overwritten
 : @return a map object with the $target-filename as key and some return message as value
~:)
declare function crud:copy($source-filename as xs:string, $target-filename as xs:string, $overwrite as xs:boolean) as map(xs:string,xs:string) {
    let $source :=
        if(doc-available($config:data-root || '/' || $source-filename))
        then doc($config:data-root || '/' || $source-filename)
        else ()
    let $create-target := 
        if($source and (not(doc-available($config:data-root || '/' || $target-filename)) or $overwrite))
        then xmldb:store($config:data-root, $target-filename, $source) => crud:adjust-mei-title()
        else ()
    return 
        map:entry(
            $target-filename,
            if($create-target)
            then 'copied successfully from ' || $source-filename
            else if(doc-available($config:data-root || '/' || $target-filename) and not($overwrite))
            then 'target already existent and "overwrite" flag was missing'
            else if($source) 
            then 'failed to create target'
            else 'source ' || $source-filename || ' does not exist'
        )
};

(:~
 : Append "copy" to the MEI title
 : Helper function for crud:copy()
 :
 : @param $filepath the (full) filepath to the resource in the eXist db
 : @return the input filepath if successfull, the empty sequence otherwise 
~:)
declare %private function crud:adjust-mei-title($filepath as xs:string?) as xs:string? {
    if(doc-available($filepath))
    then
        let $mei := doc($filepath)
        return
            try {(
                for $title in $mei//mei:workList/mei:work[1]/mei:title[text()][1]
                let $new_title_text := concat(normalize-space($title), " (copy)")
                return 
                    update value $title with $new_title_text
                ),
                $filepath
            }
            catch * {()}
    else ()
};
