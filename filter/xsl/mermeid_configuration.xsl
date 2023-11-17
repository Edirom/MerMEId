<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dcm="http://www.kb.dk/dcm"
    xmlns:xf="http://www.w3.org/2002/xforms"
    version="3.0">
    
    <xsl:param name="xslt.resources-endpoint"/>
    
    <xsl:param name="xslt.orbeon-endpoint"/>
    <xsl:param name="xslt.exist-endpoint-seen-from-orbeon"/>
    <xsl:param name="xslt.server-name"/>
    <xsl:param name="xslt.document-root"/>
    <xsl:param name="xslt.footer"/>
    
    <xsl:variable name="xforms-parameters" as="element(dcm:parameters)">
        <parameters xmlns="http://www.kb.dk/dcm">
            
            <!-- paths -->
            
            <orbeon_dir>
                <xsl:value-of select="$xslt.orbeon-endpoint"/>
            </orbeon_dir>
            <form_home>
                <xsl:value-of select="$xslt.server-name"/>/forms/</form_home>
            
            <crud_home>
                <xsl:value-of select="$xslt.exist-endpoint-seen-from-orbeon"/>/data/</crud_home>
            <library_crud_home>
                <xsl:value-of select="$xslt.exist-endpoint-seen-from-orbeon"/>/library/</library_crud_home>
            <rism_crud_home>
                <xsl:value-of select="$xslt.exist-endpoint-seen-from-orbeon"/>/rism_sigla/</rism_crud_home>
            
            <server_name>
                <xsl:value-of select="$xslt.server-name"/>
            </server_name>  
            <document_root>
                <xsl:value-of select="$xslt.document-root"/>
            </document_root>
            
            <!-- Default editor settings - (boolean; set to 'true' or nothing)  -->
            <!-- Enable automatic revisionDesc (change log) entries? -->
            <automatic_log_main_switch>true</automatic_log_main_switch>
            
            <!-- The following settings add options to the editor's settings menu -->
            <!-- Enable attribute editor? -->
            <attr_editor_main_switch>true</attr_editor_main_switch>
            <!-- Enable xml:id display component? -->
            <id_main_switch>true</id_main_switch>
            <!-- Enable code inspector component? -->
            <code_inspector_main_switch>true</code_inspector_main_switch>
            
            <footer>
                <xsl:value-of select="$xslt.footer"/>
            </footer>
            
            <!-- Some elements used internally by XForms - not for user configuration -->
            <xml_file/>
            <return_uri/>
            <this_page/>
            <attr_editor/>
            <show_id/>
            <code_inspector/>
            
        </parameters>
    </xsl:variable>
 </xsl:stylesheet>