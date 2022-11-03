<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:config="https://github.com/edirom/mermeid/config"
    xmlns:dcm="http://www.kb.dk/dcm"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:param name="config:properties-path" as="xs:string" select="concat($app-root, '/properties.xml')"/>
    
    <!--
        Return an absolute URL to the current MerMEId app for a given (relative) path 
        
        @param $relLink the relative path within the app, e.g. "/data/incipit_demo.xml"
        @return xs:string 
    -->
    <xsl:function name="config:link-to-app" as="xs:string">
        <xsl:param name="relLink" as="xs:string?"/>
        <xsl:value-of select="concat(config:get-property('exist_endpoint'), '/',  replace(normalize-space($relLink), '^/+', ''))"/>
    </xsl:function>
    
    <!--
        Return the requested property value from the properties file
        
        @param $key the element to look for in the properties file
        @return xs:string the option value as string identified by the key otherwise the empty sequence
    -->
    <xsl:function name="config:get-property" as="item()?">
        <xsl:param name="key" as="xs:string?"/>
        <xsl:variable name="properties" select="doc($config:properties-path)/dcm:properties"/>
        <xsl:variable name="result" select="$properties/dcm:*[local-name() = $key]/node()"/>
        <xsl:choose>
            <xsl:when test="$result instance of text() or $result instance of xs:anyAtomicType">
                <xsl:value-of select="normalize-space($result)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$result[. instance of element()]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
