xquery version "1.0" encoding "UTF-8";
module namespace login="http://kb.dk/this/login";

declare namespace xdb="http://exist-db.org/xquery/xmldb";

declare function login:function() as xs:boolean
{
  let $lgin := xdb:login("/db", "admin", "yourownsecretpassword")
  return $lgin
};
