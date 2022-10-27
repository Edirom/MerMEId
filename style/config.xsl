<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:config="https://github.com/edirom/mermeid/config"
    xmlns:dcm="http://www.kb.dk/dcm"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!--
        Return an absolute URL to the current MerMEId app for a given (relative) path 
        
        @param $relLink the relative path within the app, e.g. "/data/incipit_demo.xml"
        @return xs:string 
    -->
    <xsl:function name="config:link-to-app" as="xs:string">
        <xsl:param name="relLink" as="xs:string?"/>
        <xsl:param name="properties" as="element(dcm:properties)"/>
        <xsl:value-of select="concat($properties//dcm:exist_endpoint, '/',  replace(normalize-space($relLink), '^/+', ''))"/>
    </xsl:function>
    
</xsl:stylesheet>
