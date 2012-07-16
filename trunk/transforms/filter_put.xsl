<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.music-encoding.org/ns/mei" 
  xmlns:m="http://www.music-encoding.org/ns/mei" 
  xmlns:xl="http://www.w3.org/1999/xlink"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xl xlink xsl m"
  version="1.0">
  
  <xsl:output method="xml"
    encoding="UTF-8"
    omit-xml-declaration="yes" 
    indent="yes"/>
  <xsl:strip-space elements="*" />
  
  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>
  
  <!-- Generate a value for empty @xml:id -->
  <xsl:template match="@xml:id[.='']">
    <xsl:attribute name="xml:id"><xsl:value-of select="concat(name(..),'_id',generate-id())"/></xsl:attribute>
  </xsl:template>
  
  <!-- Remove empty attributes -->
  <xsl:template match="identifier/@type|@unit|@target|@targettype|@pname|@accid|@mode|@meter.count|@meter.unit|@meter.sym|@notbefore|@notafter|@reg|@n|@evidence">
    <xsl:if test="normalize-space(.)">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>    
  
  <!-- delete duplicate language definitions (fixes an xforms problem) -->
  <xsl:template match="m:mei/m:meiHead/m:workDesc/m:work/m:langUsage/m:language[. = preceding-sibling::m:language]"/>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:transform>