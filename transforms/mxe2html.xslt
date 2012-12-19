<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mxe="http://mx.dtic.dk/ns/mxe_draft"
                exclude-result-prefixes="mxe">

    <xsl:output indent="yes" method="xml"/>
    <xsl:param name="separator" select="' ; '"/>
    <xsl:param name="delineator" select="' : '"/>

    <xsl:template match="/">
        <div style="padding-top: 10px;">
            <span style="font-weight: bold;">
                <xsl:value-of select="//mxe:title/mxe:original/mxe:main"/>
            </span>
            <br/>
            <span>
                <xsl:for-each select="//mxe:person">
                    <xsl:if test="mxe:name/mxe:last != ''">
                        <xsl:if test="position() &gt; 1">
                            <xsl:value-of select="$separator" />
                        </xsl:if>
                        <xsl:value-of select="concat(mxe:name/mxe:last/text(),', ',mxe:name/mxe:first/text())"/>
                    </xsl:if>
                </xsl:for-each>
            </span>
            <span style="font-style: italic;">
                <xsl:for-each select="//mxe:organisation">
                    <xsl:if test="mxe:name/mxe:level1 != ''">
                        <xsl:if test="position() &gt; 1">
                            <xsl:value-of select="$separator"/>
                        </xsl:if>
                        <xsl:value-of select="mxe:name/mxe:level1"/>
                    </xsl:if>
                </xsl:for-each>
            </span>
            <br/>
            <br/>

            <span style="font-style: italic;"><xsl:text>Conference</xsl:text></span>
            <xsl:value-of select="$delineator"/>
            <span>
                <xsl:if test='//mxe:super_events/mxe:super_event[@event_type="conference"]/mxe:title/mxe:short'>
                    <xsl:value-of select='//mxe:super_events/mxe:super_event[@event_type="conference"]/mxe:title/mxe:short'/>
                    <xsl:text> = </xsl:text>
                </xsl:if>
                <xsl:value-of select='//mxe:super_events/mxe:super_event[@event_type="conference"]/mxe:title/mxe:main/text()'></xsl:value-of>
            </span>
            <br/>

            <xsl:if test="//mxe:date/mxe:year/text() != ''">
                <span style="font-style: italic;">
                    <xsl:text>Conference Year</xsl:text>
                </span>
                <xsl:value-of select="$delineator"/>
                <span>
                    <xsl:value-of select="//mxe:date/mxe:year"/>
                </span>
                <br/>
            </xsl:if>

            <xsl:if test="//mxe:id[@type='doi']/text() != ''">
                <span style="font-style: italic;">
                    <xsl:text>DOI</xsl:text>
                </span>
                <xsl:value-of select="$delineator"/>
                <span>
                    <xsl:value-of select="//mxe:id[@type='doi']"/>
                </span>
            </xsl:if>
            <br/>
            <xsl:if test="//mxe:description/mxe:abstract">
                <span>
                    <xsl:value-of select="normalize-space(//mxe:description/mxe:abstract)"/>
                </span>
                <br/>
                <br/>
            </xsl:if>

            <div style="clear:both;">
                <span style="float:left; padding: 5px;">
                    <label style="font-weight: bold;">Video</label>
                    <br/>
                    <xsl:if test="//mxe:documents/mxe:document[@role='video']/mxe:uri">
                        <xsl:variable name="video" select="normalize-space(//mxe:documents/mxe:document[@role='video']/mxe:uri)"/>
                        <a href="{$video}"><img src="/sites/all/modules/dtu/images/video_32.png" /></a>
                    </xsl:if>
                </span>
                <span style="float:left; padding: 5px;">
                    <label style="font-weight: bold;">Slides</label>
                    <br/>
                    <xsl:if test="//mxe:documents/mxe:document[@role='slides']/mxe:uri">
                        <xsl:variable name="slides" select="normalize-space(//mxe:documents/mxe:document[@role='slides']/mxe:uri)"/>
                        <a href="{$slides}"><img src="/sites/all/modules/dtu/images/Crystal_Clear_mimetype_pdf_32.png" /></a>
                    </xsl:if>
                </span>
                <span style="float:left; padding: 5px;">
                    <label style="font-weight: bold;">Paper</label>
                    <br/>
                    <xsl:if test="//mxe:documents/mxe:document[@role='paper']/mxe:uri">
                        <xsl:variable name="paper" select="normalize-space(//mxe:documents/mxe:document[@role='paper']/mxe:uri)"/>
                        <a href="{$paper}"><img src="/sites/all/modules/dtu/images/Crystal_Clear_mimetype_document_32.png" /></a>
                    </xsl:if>
                </span>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>