xquery version "3.0" encoding "UTF-8";

import module namespace loop="http://kb.dk/this/getlist" at "./main_loop.xqm";
import module namespace app="http://kb.dk/this/listapp"  at "./list_utils.xqm";
import module namespace config="https://github.com/edirom/mermeid/config" at "./config.xqm";
import module namespace common="https://github.com/edirom/mermeid/common" at "./common.xqm";

declare namespace xl="http://www.w3.org/1999/xlink";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";
declare namespace xi="http://www.w3.org/2001/XInclude";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace local="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";

declare option output:method "xhtml5";
declare option output:media-type "text/html";

(: get parameters, either from querystring or fall back to session attributes :)
declare variable $coll              := request:get-parameter("c", session:get-attribute("coll"));
declare variable $query             := request:get-parameter("query", session:get-attribute("query"));
declare variable $published_only    := request:get-parameter("published_only", session:get-attribute("published_only"));
declare variable $page              := xs:integer(request:get-parameter("page", session:get-attribute("page")));
declare variable $number            := xs:integer(request:get-parameter("itemsPerPage", session:get-attribute("number")));
declare variable $sortby            := request:get-parameter("sortby", session:get-attribute("sortby"));

declare variable $session := session:create();

(: save parameters as session attributes; set to default values if not defined :)
declare variable $session-coll      := session:set-attribute("coll", if ($coll!="") then $coll else "");
declare variable $session-query     := session:set-attribute("query", if ($query!="") then $query else "");
declare variable $session-published := session:set-attribute("published_only", if (not($published_only) or $published_only!="") then $published_only else "");
declare variable $session-page      := session:set-attribute("page", if ($page>0) then $page else "1");
declare variable $session-number    := session:set-attribute("number", if ($number>0) then $number else "20");
declare variable $session-sortby    := session:set-attribute("sortby", if ($sortby!="") then $sortby else "person,title");


declare variable $database := $config:data-root;

declare variable $from     := (xs:integer(session:get-attribute("page")) - 1) * xs:integer(session:get-attribute("number")) + 1;
declare variable $to       :=  $from      + xs:integer(session:get-attribute("number")) - 1;

declare variable $sort-options :=
(<option value="person,title">Composer,Title</option>,
<option value="person,date">Composer, Year</option>,
<option value="date,person">Year, Composer</option>,
<option value="date,title">Year, Title</option>,
<option value="null,work_number">Work number</option>
);


declare function local:format-reference(
  $doc as node(),
  $pos as xs:integer ) as node() {

    let $class :=
      if($pos mod 2 = 1) then 
	"odd"
      else
	"even"

	(: for some reason the sort-key function must be called outside the actual searching to have correct work number sorting when searching within all collections :)
    let $dummy := loop:sort-key("dummy_collection", $doc, "null")

	let $ref   := 
	<tr class="result {$class}">
	  <td nowrap="nowrap">
	    {common:get-composers($doc)}
	  </td>
	  <td>
	    <a target="_blank"
           title="View" 
           href="{config:link-to-app('modules/present.xq') || '?doc=' || util:document-name($doc)}">
           {common:get-title($doc)}
        </a>
      </td>
	  <td>{common:display-date($doc)}</td>
	  <td nowrap="nowrap">{common:get-edition-and-number($doc)}</td>
	  <td class="tools">
	    <form target="_blank"
            title="View XML source" 
            action="{config:link-to-app('data/read')}">
            <input type="hidden" name="filename" value="{util:document-name($doc)}"/>
            <button type="submit">
                <img src="../resources/images/xml.gif" 
                    alt="view source" 
                    border="0"
                    title="View source" />
            </button>
	    </form>
	  </td>
	  <td class="tools loginRequired">{app:edit-form-reference($doc)}</td>
	  <td class="tools loginRequired">{app:copy-document-reference($doc)}</td>
	  <td class="tools loginRequired">{app:rename-document-reference($doc)}</td>
	  <td class="tools loginRequired">{app:delete-document-reference($doc)}</td>
	  <td nowrap="nowrap">{app:view-document-notes($doc)}</td>
	</tr>
	return $ref
  };


	  
	  
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
	  <title>
	    {app:list-title()}
	  </title>
	  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
	  <link rel="styleSheet" 
	  href="../resources/css/list_style.css" 
	  type="text/css"/>
	  <link rel="styleSheet" 
	  href="../resources/css/xform_style.css" 
	  type="text/css"/>
	  <link rel="styleSheet" 
	  href="../resources/css/login.css" 
	  type="text/css"/>
	  
	  <script type="text/javascript" src="../resources/js/checkbox.js">
	  //
	  </script>
	  
	  <script type="text/javascript" src="../resources/js/publishing.js">
	  //
	  </script>
	  
	</head>
	<body class="list_files">
	  <div class="list_header">
	    <div class="header_right">
	      <div>
	       <a id="login-info" href="#" data-user="">Login</a></div>
	      <div class="loginRequired" style="display:inline;">
 	      <form id="create-file" action="{config:link-to-app('data/create')}" 
 	          method="post" class="ajaxform" title="Add new file">
 	          <label class="ajaxform_label"><b>Filename</b></label>
 	          <input type="text" name="filename" value="{common:mermeid-id('file') || '.xml'}"  
 	              class="ajaxform_input" size="40" maxlength="36"/>
               <label class="ajaxform_label"><b>Title</b></label>
               <input type="text" name="title" value="" placeholder="Please enter title"
                    class="ajaxform_input" size="40" maxlength="36"/>
                <label class="ajaxform_label">
                    <b>Overwrite target?</b>
                    <input type="checkbox" name="overwrite"/>
                </label>
     	      <button type="submit" value="New" title="Add new file"><img src="../resources/images/new.gif" alt="Add new file"/></button>
 	      </form>
	      </div>
	      <div>
	       <form id="help-link" action="{config:link-to-app('manual/index.html')}" method="get">
     	      <button type="submit" value="help" title="Help - opens the manual in a new window or tab"><img src="../resources/images/help_light.png" alt="Help"/></button>
 	      </form>
	      </div>
	    </div>
	    <img src="../resources/images/mermeid_30px.png" 
            title="MerMEId - Metadata Editor and Repository for MEI Data" 
            alt="MerMEId Logo"/>
	  </div>

	  <div class="filter_bar">
	    <table class="filter_block">
	      <tr>
		<td class="label">Filter by: &#160;</td>
		<td class="label">Collection</td>
		<td class="label">Search term <a class="help">?<span class="comment">Search terms may be combined using boolean operators. Wildcards allowed. 
                  Search is case insensitive (except for boolean operators, which must be uppercase) and will query the whole document.
                  Some examples:<br/>
                  <span class="help_table">
                    <span class="help_example">
                      <span class="help_label">carl OR nielsen</span>
                      <span class="help_value">Boolean OR (default)</span>
                    </span>                        
                    <span class="help_example">
                      <span class="help_label">carl AND nielsen</span>
                      <span class="help_value">Boolean AND</span>
                    </span>
                    <span class="help_example">
                      <span class="help_label">"carl nielsen"</span>
                      <span class="help_value">Exact phrase</span>
                    </span>
                    <span class="help_example">
                      <span class="help_label">niels*</span>
                      <span class="help_value">Match any number of characters. Finds Niels, Nielsen and Nielsson<br/>
                        (use only at end of word)
                      </span>
                    </span>
                    <span class="help_example">
                      <span class="help_label">niels?n</span>
                      <span class="help_value">Match 1 character. Finds Nielsen and Nielson, but not Nielsson</span>
                    </span>
                  </span>
                </span>
              </a></td>
	      </tr>
	      <tr>
		<td>&#160;</td>
		<td>
		  <form action="" method="get" id="collection-selection">
		      <input name="page" value="1" type="hidden"/>
    		  <select name="c" onchange="this.form.submit();">
    		    <option value="">All collections</option>
    		    {
               	      for $c in distinct-values(collection($database)[m:mei/@meiversion=$config:meiversion]//m:seriesStmt/m:identifier[@type="file_collection" and string-length(.) > 0]/string())
                        let $option :=
                		      if(not(session:get-attribute("coll")=$c)) then 
                		      <option value="{$c}">{$c}</option>
                	              else
                		      <option value="{$c}" selected="selected">{$c}</option>
                	   return $option
    		     }
    		  </select>
            </form>
          </td>
          <td>
            <form action="" method="get" class="search">
			  <input name="page" value="1" type="hidden"/>
              <input name="query"  value='{session:get-attribute("query")}'/>
              <input type="submit" value="Search"               />
              <input type="submit" value="Clear" onclick="this.form.query.value='';this.form.submit();return true;"/>
            </form>
          </td>
        </tr>
      </table>
    </div>
    {
      let $list := loop:getlist($database)
      return
      <div class="files_list">
        <div class="nav_bar">
          {app:navigation($sort-options,$list)}
        </div>
           
        <table border='0' cellpadding='0' cellspacing='0' class='result_table'>
          <tr>
            <th>Composer</th>
            <th>Title</th>
            <th>Year</th>
            <th>Collection</th>
            <th class="tools" >XML</th>
            <th class="tools">Edit</th>
            <th class="tools">Copy</th>
            <th class="tools">Rename</th>
            <th class="tools">Delete</th>
            <th>Notes</th>
          </tr>
          {
            for $doc at $count in $list[position() = ($from to $to)]
            return local:format-reference($doc,$count)
          }
        </table>
      </div>
    }
    {doc('../login.html')/*}
    {doc('../confirm.html')/*}
    {config:replace-properties(config:get-property('footer'))}
  </body>
</html>

