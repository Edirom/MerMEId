<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.music-encoding.org/ns/mei" 
    xmlns:m="http://www.music-encoding.org/ns/mei" 
    xmlns:xl="http://www.w3.org/1999/xlink"
    xmlns:zs="http://www.loc.gov/zing/srw/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns:dcm="http://www.kb.dk/dcm"
    exclude-result-prefixes="xsl m zs marc xl xsi dcm"
    version="2.0">
    
    <!--
  
        Filter out records containing RISM sigla and sort them according to country.
        The intended input file is the complete list of RISM institutions and names: institution-latest.xml 
        (included in https://rism.digital/exports/institution-latest.xml.gz 
        which is listed at https://rism.digital/exports/index.html).
        For use with MerMEId, the output should be split into sections by country and saved as separate files
        named A.xml, AFG.xml etc.
  
    -->
    
    <!-- 
        Directory containing the rism sigla files A.xml, AFG.xml etc.
        This defaults to the current directory so please adjust if you 
        want the files to be saved somewhere else 
    -->
    <xsl:param name="rism_sigla.dir" select="'.'"/>
    
    <xsl:output method="xml"
        encoding="UTF-8"
        omit-xml-declaration="no" 
        indent="yes"/>
    
    <xsl:strip-space elements="*" /> 
    
    <xsl:template match="/">
        <rismSigla xmlns="http://www.kb.dk/dcm">
            <xsl:text>&#10;</xsl:text>
            <xsl:comment> Nothing to see here. The individual files for every country (A.xml, AFG.xml etc.) should have been saved to the directory <xsl:value-of select="$rism_sigla.dir"/> </xsl:comment>
            <xsl:text>&#10;</xsl:text>
            <xsl:for-each-group select="/marc:collection/marc:record" group-by="substring-before(marc:datafield[@tag='110']/marc:subfield[@code='g']/text(),'-')">
                <xsl:sort select="current-grouping-key()"/>
                <xsl:choose>
                    <!-- some entries miss proper RISM-Sigla and will be excluded here -->
                    <xsl:when test="current-grouping-key()=''"/>
                    <!-- otherwise  -->
                    <xsl:otherwise>
                        <xsl:variable name="filename" select="replace(string-join(($rism_sigla.dir, concat(current-grouping-key(), '.xml')), '/'), '//', '/')"/>
                        <xsl:result-document href="{$filename}">
                            <xsl:message>Writing file <xsl:value-of select="$filename"/></xsl:message>
                            <collection xmlns="http://www.loc.gov/MARC21/slim">
                                <xsl:for-each select="current-group()">
                                    <xsl:sort select="marc:datafield[@tag='110']/marc:subfield[@code='g']"/>
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                            </collection>
                        </xsl:result-document>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </rismSigla>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:transform>
