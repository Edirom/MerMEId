xquery version "3.1";

(:~
 : Basic CRUD (Create, Read, Update, Delete) functions for the MerMEId data store
 :
 : All operations assume data is kept at $config:data-root and the file hierarchy is flat,
 : i.e. there are no subfolders
 :)
module namespace crud="https://github.com/edirom/mermeid/crud";

declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace map="http://www.w3.org/2005/xpath-functions/map";
declare namespace err="http://www.w3.org/2005/xqt-errors";
declare namespace jb="http://exist.sourceforge.net/NS/exist/java-binding";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace sm="http://exist-db.org/xquery/securitymanager";

import module namespace config="https://github.com/edirom/mermeid/config" at "config.xqm";
import module namespace common="https://github.com/edirom/mermeid/common" at "common.xqm";

(:~
 : Delete files within the data directory
 :
 : @param $filenames the files to delete
 : @return an array of map object with filename, message and code properties concerning the delete operation
 :)
declare function crud:delete($filenames as xs:string*) as array(map(xs:string,xs:string)*) {
    array {
        for $filename in $filenames
        return
            try {(
                xmldb:remove($config:data-root, $filename), 
                map {
                    'filename': $filename,
                    'message': 'deleted successfully',
                    'code': 200
                }
            )}
            catch jb:org.xmldb.api.base.XMLDBException {
                map {
                    'filename': $filename,
                    'message': 'failed to delete: ' || $err:description,
                    'code': 401
                }
            }
            catch * {
                map {
                    'filename': $filename,
                    'message': 'failed to delete: ' || string-join(($err:code, $err:description), '; '),
                    'code': 500
                }
            }
    }
};

(:~
 : Create a file within the data directory
 :
 : @param $node the XML document to store
 : @param $filename the filename for the new file
 : @param $overwrite whether an existent file may be overwritten
 : @return a map object with filename, message and code properties concerning the create operation
 :)
declare function crud:create($node as node(), $filename as xs:string, $overwrite as xs:boolean) as map(*) {
    try {
        if(not(doc-available($config:data-root || '/' || $filename)) or $overwrite)
        then if(xmldb:store($config:data-root, $filename, $node))
        then crud:read($filename) => map:put('message', 'created successfully') 
        else map {
            'filename': $filename,
            'message': 'failed to create file',
            'code': 500
        }
        else map {
            'filename': $filename,
            'message': 'file already exists and no overwrite flag was set',
            'code': 401
        }
    }
    catch jb:org.xmldb.api.base.XMLDBException {
        map {
            'filename': $filename,
            'message': 'failed to create file: ' || $err:description,
            'code': 401
        }
    }
    catch * {
        map {
            'filename': $filename,
            'message': 'failed to create file: ' || string-join(($err:code, $err:description), '; '),
            'code': 500
        }
    }
};

(:~
 : Copy a file within the data directory
 :
 : @param $source-filename the input filename to copy
 : @param $target-filename the output filename to copy to
 : @param $overwrite whether an existent target file may be overwritten
 : @param $new_title an optional new title. If omitted, the string "(copy)" will be appended to the old title
 : @return a map object with source, target, message and code properties concerning the copy operation
 :)
declare function crud:copy($source-filename as xs:string, $target-filename as xs:string, 
    $overwrite as xs:boolean, $new_title as xs:string?) as map(*) {
    let $source :=
        if(doc-available($config:data-root || '/' || $source-filename))
        then doc($config:data-root || '/' || $source-filename)[mei:mei/@meiversion=$config:meiversion]
        else ()
    let $title := 
        if($new_title) 
        then $new_title
        else common:get-title($source) || ' (Copy)'
    let $username := common:get-current-username() => string()
    let $change-message := 'file copied from ' || $source-filename || ' to ' || $target-filename
    let $create-target := 
        if($source) then crud:create($source => common:set-mei-title-in-memory($title) => common:add-change-entry-to-revisionDesc-in-memory($username, $change-message), $target-filename, $overwrite)
        else ()
    return
        if($create-target instance of map(*)) 
        then $create-target => map:put('title', $new_title)
        else map {
            'source': $source-filename,
            'target': $target-filename,
            'message': 'source does not exist',
            'code': 404
        } 
};

(:~
 : Read a file from the data directory
 :
 : @param $filename the filename (aka MerMEId identifier) to read
 : @return a map object with some metadata (e.g. "title", "composer") and the complete MEI document as "document-node"
 :)
declare function crud:read($filename as xs:string) as map(*) {
    let $doc :=
        if(doc-available($config:data-root || '/' || $filename))
        then doc($config:data-root || '/' || $filename)[mei:mei/@meiversion=$config:meiversion]
        else ()
    return
        if($doc)
        then map {
            'filename': $filename,
            'document-node': $doc,
            'composer': common:get-composers($doc),
            'title': common:get-title($doc),
            'year': common:display-date($doc),
            'collection': common:get-edition-and-number($doc),
            'message': 'read successfully',
            'code': 200
        }
        else map {
            'filename': $filename,
            'message': 'file not found or permissions missing',
            'code': 404
        }
};
