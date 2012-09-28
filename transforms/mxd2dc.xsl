<?xml version="1.0"?>

<!-- $Id: mxd2dc.xsl 80 2008-09-25 12:47:27Z franck $ -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://exslt.org/strings"
    xmlns:mxd="http://mx.forskningsdatabasen.dk/ns/mxd/"
    extension-element-prefixes="str"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">

    <xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="no" encoding="utf-8"/>

    <xsl:template match="/">
        <xsl:apply-templates select="mxd:ddf_doc"/>
    </xsl:template>

    <xsl:template match="/mxd:ddf_doc">
        <xsl:element name="oai_dc:dc">
            <xsl:attribute name="dc:dummy"/>
            <xsl:attribute name="xsi:dummy"/>
            <xsl:attribute name="mxd:dummy"/>
            <xsl:apply-templates select="mxd:title/mxd:original"/>
            <xsl:apply-templates select="mxd:person/mxd:name"/>
            <xsl:apply-templates select="mxd:description/mxd:subject/mxd:keyword"/>
            <xsl:apply-templates select="mxd:description/mxd:abstract"/>
            <xsl:apply-templates select="mxd:publication/*/mxd:publisher"/>
            <xsl:apply-templates select="mxd:organisation/mxd:name"/>
            <xsl:apply-templates select="mxd:publication/*/mxd:year"/>
            <xsl:apply-templates select="mxd:publication/mxd:patent/mxd:date"/>
            <xsl:apply-templates select="mxd:publication/*/mxd:issn"/>
            <xsl:apply-templates select="mxd:publication/*/mxd:isbn"/>
            <xsl:apply-templates select="mxd:publication/*/mxd:uri"/>
            <xsl:apply-templates select="mxd:publication/mxd:in_journal"/>
            <xsl:apply-templates select="mxd:publication/mxd:in_book"/>
            <xsl:apply-templates select="mxd:publication/mxd:in_report"/>
            <xsl:apply-templates select="mxd:publication/mxd:book"/>
            <xsl:apply-templates select="mxd:publication/mxd:patent"/>
            <xsl:apply-templates select="@doc_lang"/>
            <xsl:apply-templates select="mxd:project/mxd:title"/>
            <xsl:apply-templates select="mxd:event"/>
            <dc:coverage>Partial representation, see MXD format for full meta-data</dc:coverage>
            <xsl:apply-templates select="@doc_type"/>
        </xsl:element>
    </xsl:template>
    
<!--Title-->
    <xsl:template match="//mxd:title/mxd:original">
        <dc:title>
            <xsl:value-of select="mxd:main"/>
            <xsl:if test="mxd:main">
                <xsl:if test="mxd:sub or mxd:part">
                    <xsl:text> : </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxd:sub"/>
            <xsl:if test="mxd:sub and mxd:part">
                <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:value-of select="mxd:part"/>
        </dc:title>
    </xsl:template>

<!--Creator-->
    <xsl:template match="//mxd:person/mxd:name">
        <dc:creator>
            <xsl:value-of select="mxd:last"/>
            <xsl:if test="mxd:last and mxd:first">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="mxd:first"/>
        </dc:creator>
    </xsl:template>

<!--Subject-->
    <xsl:template match="//mxd:description/mxd:subject/mxd:keyword">
        <dc:subject>
            <xsl:value-of select="."/>
        </dc:subject>
    </xsl:template>

<!--Description-->
    <xsl:template match="//mxd:description/mxd:abstract">
        <dc:description>
            <xsl:value-of select="."/>
        </dc:description>
    </xsl:template>

<!--Publisher-->
    <xsl:template match="//mxd:publication/*/mxd:publisher">
        <dc:publisher>
            <xsl:value-of select="."/>
        </dc:publisher>
    </xsl:template>

<!--Contributor-->
    <xsl:template match="//mxd:organisation/mxd:name">
        <dc:contributor>
            <xsl:call-template name="sepn">
                <xsl:with-param name="e1" select="mxd:level1"/>
                <xsl:with-param name="e2" select="mxd:level2"/>
                <xsl:with-param name="e3" select="mxd:level3"/>
                <xsl:with-param name="e4" select="mxd:level4"/>
                <xsl:with-param name="sep" select="', '"/>
            </xsl:call-template>
            <xsl:if test="mxd:level1 or mxd:level2 or mxd:level3 or mxd:level4">
                <xsl:if test="mxd:acronym">
                    <xsl:text> - </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxd:acronym"/>
        </dc:contributor>
    </xsl:template>

<!--Publisher-->
    <xsl:template match="//mxd:publication/*/mxd:year">
        <dc:date>
            <xsl:value-of select="."/>
        </dc:date>
    </xsl:template>

    <xsl:template match="//mxd:publication/mxd:patent/mxd:date">
        <dc:date>
            <xsl:value-of select="."/>
        </dc:date>
    </xsl:template>

<!--Identifier-->
    <xsl:template match="//mxd:publication/*/mxd:issn">
        <dc:identifier>
            <xsl:value-of select="."/>
        </dc:identifier>
    </xsl:template>

    <xsl:template match="//mxd:publication/*/mxd:isbn">
        <dc:identifier>
            <xsl:value-of select="."/>
        </dc:identifier>
    </xsl:template>

    <xsl:template match="//mxd:publication/*/mxd:uri">
        <dc:identifier>
            <xsl:value-of select="."/>
        </dc:identifier>
    </xsl:template>

<!--Source-->
    <xsl:template match="//mxd:publication/mxd:in_journal">
        <dc:source>
            <xsl:value-of select="mxd:title"/>
            <xsl:if test="mxd:title">
                <xsl:if test="mxd:vol or mxd:issue or mxd:pages or mxd:series">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxd:vol"/>
            <xsl:if test="mxd:vol">
                <xsl:if test="mxd:issue or mxd:pages">
                    <xsl:text> - </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:call-template name="sepn">
                <xsl:with-param name="e1" select="mxd:issue"/>
                <xsl:with-param name="e2" select="mxd:pages"/>
                <xsl:with-param name="sep" select="', '"/>
            </xsl:call-template>
            <xsl:if test="mxd:series">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="mxd:series"/>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </dc:source>
    </xsl:template>

    <xsl:template match="//mxd:publication/mxd:in_book">
        <dc:source>
            <xsl:value-of select="mxd:title"/>
            <xsl:if test="mxd:title and mxd:part">
                <xsl:text>; </xsl:text>
            </xsl:if>
            <xsl:value-of select="mxd:part"/>
            <xsl:if test="mxd:edition">
                <xsl:text> [</xsl:text>
                <xsl:value-of select="mxd:edition"/>
                <xsl:text>]</xsl:text>
                <xsl:if test="mxd:pages">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:if test="mxd:part or mxd:edition">
                <xsl:if test="mxd:pages">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxd:pages"/>
            <xsl:if test="mxd:series">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="mxd:series"/>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </dc:source>
    </xsl:template>

    <xsl:template match="//mxd:publication/mxd:in_report">
        <dc:source>
            <xsl:value-of select="mxd:title"/>
            <xsl:if test="mxd:title">
                <xsl:if test="mxd:report_no or mxd:pages">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:call-template name="sepn">
                <xsl:with-param name="e1" select="mxd:report_no"/>
                <xsl:with-param name="e2" select="mxd:pages"/>
                <xsl:with-param name="sep" select="', '"/>
            </xsl:call-template>
        </dc:source>
    </xsl:template>

    <xsl:template match="//mxd:publication/mxd:book">
        <dc:source>
            <xsl:if test="mxd:edition">
                <xsl:text> [</xsl:text>
                <xsl:value-of select="mxd:edition"/>
                <xsl:text>]</xsl:text>
                <xsl:if test="mxd:pages">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxd:pages"/>
            <xsl:if test="mxd:series">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="mxd:series"/>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </dc:source>
    </xsl:template>

    <xsl:template match="//mxd:publication/mxd:patent">
        <dc:source>
            <xsl:call-template name="sepn">
                <xsl:with-param name="e1" select="mxd:country"/>
                <xsl:with-param name="e2" select="mxd:ipc"/>
                <xsl:with-param name="sep" select="', '"/>
            </xsl:call-template>
            <xsl:if test="mxd:country or mxd:ipc">
                <xsl:if test="mxd:number">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxd:number"/>
        </dc:source>
    </xsl:template>

<!--Language-->
    <xsl:template match="/mxd:ddf_doc/@doc_lang">
        <dc:language>
            <xsl:value-of select="."/>
        </dc:language>
    </xsl:template>

<!--Relation-->
    <xsl:template match="//mxd:project/mxd:title">
        <dc:relation>
            <xsl:call-template name="sepn">
                <xsl:with-param name="e1" select="mxd:main"/>
                <xsl:with-param name="e2" select="mxd:sub"/>
                <xsl:with-param name="e3" select="mxd:acronym"/>
                <xsl:with-param name="sep" select="' : '"/>
            </xsl:call-template>
        </dc:relation>
    </xsl:template>

    <xsl:template match="//mxd:event">
        <dc:relation>
            <xsl:call-template name="sepn">
                <xsl:with-param name="e1" select="mxd:title/mxd:full"/>
                <xsl:with-param name="e2" select="mxd:title/mxd:acronym"/>
                <xsl:with-param name="sep" select="', '"/>
            </xsl:call-template>
            <xsl:if test="mxd:title/mxd:full or mxd:title/mxd:acronym">
                <xsl:if test="mxd:title/mxd:number or mxd:place">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="mxd:title/mxd:number"/>
            <xsl:if test="mxd:title/mxd:number and mxd:place">
                <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:value-of select="mxd:place"/>
        </dc:relation>
    </xsl:template>

<!--Type-->
    <xsl:template match="//mxd:ddf_doc/@doc_type">
        <dc:type>
            <xsl:choose>
                <xsl:when test=".='dja'">
                    <xsl:text>Journal article</xsl:text>
                </xsl:when>
                <xsl:when test=".='djl'">
                    <xsl:text>Journal comment/letter/rev.</xsl:text>
                </xsl:when>
                <xsl:when test=".='dna'">
                    <xsl:text>Newspaper article</xsl:text>
                </xsl:when>
                <xsl:when test=".='db'">
                    <xsl:text>Book</xsl:text>
                </xsl:when>
                <xsl:when test=".='dba'">
                    <xsl:text>Book chapter</xsl:text>
                </xsl:when>
                <xsl:when test=".='dbp'">
                    <xsl:text>Book preface, encycl. entry</xsl:text>
                </xsl:when>
                <xsl:when test=".='dr'">
                    <xsl:text>Report</xsl:text>
                </xsl:when>
                <xsl:when test=".='dra'">
                    <xsl:text>Report chapter</xsl:text>
                </xsl:when>
                <xsl:when test=".='dcp'">
                    <xsl:text>Conference paper</xsl:text>
                </xsl:when>
                <xsl:when test=".='dca'">
                    <xsl:text>Conference abstract</xsl:text>
                </xsl:when>
                <xsl:when test=".='dco'">
                    <xsl:text>Conference poster</xsl:text>
                </xsl:when>
                <xsl:when test=".='dct'">
                    <xsl:text>Conference talk</xsl:text>
                </xsl:when>
                <xsl:when test=".='dw'">
                    <xsl:text>Working paper, preprint</xsl:text>
                </xsl:when>
                <xsl:when test=".='dln'">
                    <xsl:text>Lecture notes</xsl:text>
                </xsl:when>
                <xsl:when test=".='dl'">
                    <xsl:text>Lecture</xsl:text>
                </xsl:when>
                <xsl:when test=".='dp'">
                    <xsl:text>Patent</xsl:text>
                </xsl:when>
                <xsl:when test=".='dtd'">
                    <xsl:text>Thesis Doctoral</xsl:text>
                </xsl:when>
                <xsl:when test=".='dtp'">
                    <xsl:text>Thesis PhD</xsl:text>
                </xsl:when>
                <xsl:when test=".='dtm'">
                    <xsl:text>Thesis Master</xsl:text>
                </xsl:when>
                <xsl:when test=".='dts'">
                    <xsl:text>Student report</xsl:text>
                </xsl:when>
                <xsl:when test=".='dso'">
                    <xsl:text>Software</xsl:text>
                </xsl:when>
                <xsl:when test=".='dd'">
                    <xsl:text>Data set</xsl:text>
                </xsl:when>
                <xsl:when test=".='drt'">
                    <xsl:text>Radio/TV broadcast</xsl:text>
                </xsl:when>
                <xsl:when test=".='dx'">
                    <xsl:text>Exhibition catalogue</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Unknown</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="/mxd:ddf_doc/@doc_review='pr'">
                    <xsl:text> (Peer reviewed)</xsl:text>
                </xsl:when>
                <xsl:when test="/mxd:ddf_doc/@doc_review='or'">
                    <xsl:text> (Reviewed)</xsl:text>
                </xsl:when>
                <xsl:when test="/mxd:ddf_doc/@doc_review='nr'">
                    <xsl:text> (Not reviewed)</xsl:text>
                </xsl:when>
            </xsl:choose>
        </dc:type>
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
