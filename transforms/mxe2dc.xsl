<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    This stylesheet attempts to transform DTU's undocumented "MXE" event 
    metadata documents to Dublin Core 1.1.
    
    The style was tested only with a pair of example MXE files and will likely
    require revision as edge cases reveal additional functionality not 
    found in the two sample docs.
    
    Version 0.1     2012-08-31      Zachary Howarth-Schueler <zac@discoverygarden.ca>
-->
<xsl:stylesheet version="1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mxe="http://mx.dtic.dk/ns/mxe_draft"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="str mxe"
    xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">

    <xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes" encoding="utf-8"/>

    <xsl:template match="/">
        <xsl:apply-templates select="mxe:eve"/>
    </xsl:template>

    <xsl:template match="/mxe:eve">
        <xsl:element name="oai_dc:dc">
            <xsl:attribute name="dc:dummy"/>
            <xsl:attribute name="xsi:dummy"/>
            <xsl:attribute name="mxe:dummy"/>
            <xsl:apply-templates select="mxe:title"/>
            <xsl:apply-templates select="mxe:person/mxe:name"/>
            <xsl:apply-templates select="mxe:description/mxe:subject/mxe:keyword"/>
            <xsl:apply-templates select="mxe:description/mxe:abstract"/>
<!--            <xsl:apply-templates select="mxe:publication/*/mxe:publisher"/>-->
            <xsl:apply-templates select="mxe:organisation/mxe:name"/>
<!--            <xsl:apply-templates select="mxe:publication/*/mxe:year"/>-->
            <xsl:apply-templates select="mxe:date/mxe:year"/>
<!--            <xsl:apply-templates select="mxe:publication/mxe:patent/mxe:date"/>-->
            <xsl:apply-templates select="mxe:id"/>
            <xsl:apply-templates select="mxe:uri"/>
<!--            <xsl:apply-templates select="mxe:publication/*/mxe:issn"/>-->
<!--            <xsl:apply-templates select="mxe:publication/*/mxe:isbn"/>-->
<!--            <xsl:apply-templates select="mxe:publication/mxe:in_journal"/>-->
<!--            <xsl:apply-templates select="mxe:publication/mxe:in_book"/>-->
<!--            <xsl:apply-templates select="mxe:publication/mxe:in_report"/>-->
<!--            <xsl:apply-templates select="mxe:publication/mxe:book"/>-->
<!--            <xsl:apply-templates select="mxe:publication/mxe:patent"/>-->
            <xsl:apply-templates select="@eve_lang"/>
<!--            <xsl:apply-templates select="mxe:project/mxe:title"/>-->
            <xsl:apply-templates select="mxe:super_events/mxe:super_event"/>
            <dc:coverage>Partial representation, see mxe format for full meta-data</dc:coverage>
<!--            <xsl:apply-templates select="@doc_type"/>-->
            <xsl:apply-templates select="@eve_type"/>
            <xsl:apply-templates select="mxe:documents/mxe:document"/>
        </xsl:element>
    </xsl:template>
    
<!--Title-->
    <xsl:template match="//mxe:title">
        <dc:title>
            <xsl:value-of select="mxe:original/mxe:main"/>
            <xsl:if test="mxe:original/mxe:main">
                <xsl:if test="mxe:original/mxe:sub or mxe:original/mxe:short">
                    <xsl:text> : </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxe:original/mxe:sub"/>
            <xsl:if test="mxe:original/mxe:sub and mxe:original/mxe:short">
                <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:value-of select="mxe:original/mxe:short"/>
            <xsl:if test="mxe:number or mxe:place">
                <xsl:text>; </xsl:text>
            </xsl:if>
            <!-- Move number / place from MXD's event to here
                 and copy short title stuff to new super_event -->
            <xsl:value-of select="mxe:number"/>
            <xsl:if test="mxe:number and mxe:place">
                <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:value-of select="mxe:place"/>
        </dc:title>
    </xsl:template>

<!--Creator-->
<!-- (same as MXD) -->
    <xsl:template match="//mxe:person/mxe:name">
        <dc:creator>
            <xsl:value-of select="mxe:last"/>
            <xsl:if test="mxe:last and mxe:first">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="mxe:first"/>
        </dc:creator>
    </xsl:template>

<!--Subject-->
<!-- (same as MXD) -->
    <xsl:template match="//mxe:description/mxe:subject/mxe:keyword">
        <dc:subject>
            <xsl:value-of select="."/>
        </dc:subject>
    </xsl:template>

<!--Description-->
<!-- (same as MXD) -->
    <xsl:template match="//mxe:description/mxe:abstract">
        <dc:description>
            <xsl:value-of select="."/>
        </dc:description>
    </xsl:template>

<!--Publisher-->
<!-- Seems not to be part of MXE - left around just in case -->
    <xsl:template match="//mxe:publication/*/mxe:publisher">
        <dc:publisher>
            <xsl:value-of select="."/>
        </dc:publisher>
    </xsl:template>

<!--Contributor-->
    <xsl:template match="//mxe:organisation/mxe:name">
        <dc:contributor>
            <xsl:call-template name="sepn">
                <xsl:with-param name="e1" select="mxe:level1"/>
                <xsl:with-param name="e2" select="mxe:level2"/>
                <xsl:with-param name="e3" select="mxe:level3"/>
                <xsl:with-param name="e4" select="mxe:level4"/>
                <xsl:with-param name="sep" select="', '"/>
            </xsl:call-template>
            <xsl:if test="mxe:level1 or mxe:level2 or mxe:level3 or mxe:level4">
                <xsl:if test="mxe:acronym">
                    <xsl:text> - </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxe:acronym"/>
        </dc:contributor>
    </xsl:template>

<!-- Raw Date - Added for MXE -->
    <xsl:template match="//mxe:eve/mxe:date/mxe:year">
        <dc:date>
            <xsl:value-of select="."/>
        </dc:date>
    </xsl:template>

<!--Publisher-->
<!-- Not used in MXE apparently -->
    <xsl:template match="//mxe:publication/*/mxe:year">
        <dc:date>
            <xsl:value-of select="."/>
        </dc:date>
    </xsl:template>

    <xsl:template match="//mxe:publication/mxe:patent/mxe:date">
        <dc:date>
            <xsl:value-of select="."/>
        </dc:date>
    </xsl:template>

<!--Identifier-->
    <!-- Fedora PID -->
    <xsl:template match="//mxe:eve/mxe:id[@type='rep_id']">
        <dc:identifier>
            <xsl:value-of select="."/>
        </dc:identifier>
    </xsl:template>

    <!-- URI -->
    <xsl:template match="//mxe:eve/mxe:uri">
        <dc:identifier>
            <xsl:value-of select="."/>
        </dc:identifier>
    </xsl:template>
    
    <!-- Remainder unused: -->
    <xsl:template match="//mxe:publication/*/mxe:issn">
        <dc:identifier>
            <xsl:value-of select="."/>
        </dc:identifier>
    </xsl:template>

    <xsl:template match="//mxe:publication/*/mxe:isbn">
        <dc:identifier>
            <xsl:value-of select="."/>
        </dc:identifier>
    </xsl:template>

<!--Source-->
<!-- Unused as such in MXE -->
    <xsl:template match="//mxe:publication/mxe:in_journal">
        <dc:source>
            <xsl:value-of select="mxe:title"/>
            <xsl:if test="mxe:title">
                <xsl:if test="mxe:vol or mxe:issue or mxe:pages or mxe:series">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxe:vol"/>
            <xsl:if test="mxe:vol">
                <xsl:if test="mxe:issue or mxe:pages">
                    <xsl:text> - </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:call-template name="sepn">
                <xsl:with-param name="e1" select="mxe:issue"/>
                <xsl:with-param name="e2" select="mxe:pages"/>
                <xsl:with-param name="sep" select="', '"/>
            </xsl:call-template>
            <xsl:if test="mxe:series">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="mxe:series"/>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </dc:source>
    </xsl:template>

    <xsl:template match="//mxe:publication/mxe:in_book">
        <dc:source>
            <xsl:value-of select="mxe:title"/>
            <xsl:if test="mxe:title and mxe:part">
                <xsl:text>; </xsl:text>
            </xsl:if>
            <xsl:value-of select="mxe:part"/>
            <xsl:if test="mxe:edition">
                <xsl:text> [</xsl:text>
                <xsl:value-of select="mxe:edition"/>
                <xsl:text>]</xsl:text>
                <xsl:if test="mxe:pages">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:if test="mxe:part or mxe:edition">
                <xsl:if test="mxe:pages">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxe:pages"/>
            <xsl:if test="mxe:series">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="mxe:series"/>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </dc:source>
    </xsl:template>

    <xsl:template match="//mxe:publication/mxe:in_report">
        <dc:source>
            <xsl:value-of select="mxe:title"/>
            <xsl:if test="mxe:title">
                <xsl:if test="mxe:report_no or mxe:pages">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:call-template name="sepn">
                <xsl:with-param name="e1" select="mxe:report_no"/>
                <xsl:with-param name="e2" select="mxe:pages"/>
                <xsl:with-param name="sep" select="', '"/>
            </xsl:call-template>
        </dc:source>
    </xsl:template>

    <xsl:template match="//mxe:publication/mxe:book">
        <dc:source>
            <xsl:if test="mxe:edition">
                <xsl:text> [</xsl:text>
                <xsl:value-of select="mxe:edition"/>
                <xsl:text>]</xsl:text>
                <xsl:if test="mxe:pages">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxe:pages"/>
            <xsl:if test="mxe:series">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="mxe:series"/>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </dc:source>
    </xsl:template>

    <xsl:template match="//mxe:publication/mxe:patent">
        <dc:source>
            <xsl:call-template name="sepn">
                <xsl:with-param name="e1" select="mxe:country"/>
                <xsl:with-param name="e2" select="mxe:ipc"/>
                <xsl:with-param name="sep" select="', '"/>
            </xsl:call-template>
            <xsl:if test="mxe:country or mxe:ipc">
                <xsl:if test="mxe:number">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxe:number"/>
        </dc:source>
    </xsl:template>

<!--Language-->
    <xsl:template match="/mxe:eve/@eve_lang">
        <dc:language>
            <xsl:value-of select="."/>
        </dc:language>
    </xsl:template>

<!--Relation-->
<!-- Apparently unused in MXE -->
    <xsl:template match="//mxe:project/mxe:title">
        <dc:relation>
            <xsl:call-template name="sepn">
                <xsl:with-param name="e1" select="mxe:main"/>
                <xsl:with-param name="e2" select="mxe:sub"/>
                <xsl:with-param name="e3" select="mxe:acronym"/>
                <xsl:with-param name="sep" select="' : '"/>
            </xsl:call-template>
        </dc:relation>
    </xsl:template>

<!-- Parent Event -->
    <xsl:template match="//mxe:super_events/mxe:super_event">
        <xsl:if test="@event_type = 'conference' or @event_type = 'recurring'">
            <dc:relation>
                <xsl:call-template name="sepn">
                    <xsl:with-param name="e1" select="mxe:title/mxe:main"/>
                    <xsl:with-param name="e2" select="mxe:title/mxe:short"/>
                    <xsl:with-param name="sep" select="', '"/>
                </xsl:call-template>
<!--
                <xsl:if test="mxe:title/mxe:main or mxe:title/mxe:short">
                    <xsl:if test="mxe:title/mxe:number or mxe:place">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:if>
                <xsl:value-of select="mxe:title/mxe:number"/>
                <xsl:if test="mxe:title/mxe:number and mxe:place">
                    <xsl:text> - </xsl:text>
                </xsl:if>
                <xsl:value-of select="mxe:place"/>
-->
            </dc:relation>
            <xsl:if test="@id">
                <dc:relation>
                    <xsl:value-of select="@id"/>
                </dc:relation>
            </xsl:if>
            <xsl:if test="mxe:organisation">
                <dc:contributor>
                    <xsl:value-of select="mxe:organisation"/>
                </dc:contributor>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
<!-- Sub-Events - actually, ignore these-->

<!--Event Type -->
<!-- Event type codes undocumented.  
    List includes:
        - eco
        - ecoco
        - ???
    But let's not get too detailed, the object is by nature an "event"
-->
    <xsl:template match="//mxe:eve/@eve_type">
        <dc:type>
            <xsl:text>Event</xsl:text>
        </dc:type>
    </xsl:template>
    
<!-- Documents -->
    <xsl:template match="//mxe:eve/mxe:documents/mxe:document">
        <xsl:if test="@id">
            <dc:relation>
                <xsl:value-of select="@id"/>
            </dc:relation>
        </xsl:if>
    </xsl:template>
    

<!--General functions-->
    <xsl:template name="sepn">
        <xsl:param name="e1"/>
        <xsl:param name="e2"/>
        <xsl:param name="e3"/>
        <xsl:param name="e4"/>
        <xsl:param name="e5"/>
        <xsl:param name="e6"/>
        <xsl:param name="e7"/>
        <xsl:param name="e8"/>
        <xsl:param name="sep"/>
        <xsl:param name="posfix"/>
        <xsl:param name="sub"/>
        <xsl:if test="string-length (concat ($e1, $e2, $e3, $e4, $e5, $e6, $e7, $e8, $sub))">
            <xsl:choose>
                <xsl:when test="string-length (concat ($e1, $e2, $e3, $e4, $e5, $e6, $e7, $e8))">
                    <xsl:apply-templates select="$e1"/>
                    <xsl:if test="string-length ($e1) and string-length (concat ($e2, $e3, $e4, $e5, $e6, $e7, $e8))">
                        <xsl:choose>
                            <xsl:when test="$sep='.br.'">
                                <br/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$sep"/><xsl:text/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:call-template name="sepn">
                        <xsl:with-param name="e1" select="$e2"/>
                        <xsl:with-param name="e2" select="$e3"/>
                        <xsl:with-param name="e3" select="$e4"/>
                        <xsl:with-param name="e4" select="$e5"/>
                        <xsl:with-param name="e5" select="$e6"/>
                        <xsl:with-param name="e6" select="$e7"/>
                        <xsl:with-param name="e7" select="$e8"/>
                        <xsl:with-param name="sep" select="$sep"/>
                        <xsl:with-param name="posfix" select="$posfix"/>
                        <xsl:with-param name="sub" select="'true'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$posfix='.br.'">
                            <br/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$posfix"/><xsl:text/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>