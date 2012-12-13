<?xml version="1.0" encoding="UTF-8"?>
<!-- MXE Conference -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:foxml="info:fedora/fedora-system:def/foxml#"
		xmlns:mxe="http://mx.dtic.dk/ns/mxe_draft"
                exclude-result-prefixes="mxe"
>

    <xsl:template match="foxml:datastream[@ID='MXE']/foxml:datastreamVersion[last()]">
         <xsl:param name="content"/>
       	 <xsl:param name="prefix">mxe_</xsl:param>
         <xsl:param name="suffix">_ms</xsl:param>
        
        <!-- Type -->
        <xsl:for-each select="$content/mxe:eve/">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'type', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="@eve_type"/>
            </field>
        </xsl:for-each>

        <!-- Title -->
        <xsl:for-each select="$content/mxe:eve/mxe:title/mxe:original/mxe:main[normalize-space(text())]">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'title', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="text()"/>
            </field>
        </xsl:for-each>

        <!-- Abstract -->
        <xsl:for-each select="$content/mxe:eve/mxe:description/mxe:abstract[normalize-space(text())]">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'abstract', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="text()"/>
            </field>
        </xsl:for-each>


        <!-- Year -->
        <xsl:for-each select="$content/mxe:eve/mxe:date/mxe:year[normalize-space(text())]">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'year', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="text()"/>
            </field>
        </xsl:for-each>

        <!-- Author -->
        <xsl:for-each select="$content/mxe:eve/mxe:person/mxe:name">
             <xsl:if test="mxe:last != '' and mxe:first != ''">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'author', $suffix)"/>
                </xsl:attribute>
                <xsl:for-each select="mxe:last">
                    <xsl:value-of select="text()"/>
                </xsl:for-each>
                <xsl:text>, </xsl:text>

                <xsl:for-each select="mxe:first">
                    <xsl:value-of select="text()"/>
                </xsl:for-each>
            </field>
            </xsl:if>
        </xsl:for-each>

        <!-- Conference -->
        <xsl:for-each
                select="$content/mxe:eve/mxe:super_events/mxe:super_event[@event_type='conference']/mxe:title/mxe:main[normalize-space(text())]">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'conference', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="text()"/>
            </field>
        </xsl:for-each>

        <!-- Session -->
        <xsl:for-each select="$content/mxe:eve/mxe:super_events/mxe:super_event[@event_type='ses']/mxe:title[normalize-space(text())]">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'session', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="text()"/>
            </field>
        </xsl:for-each>

        <!-- Track -->
        <xsl:for-each select="$content/mxe:eve/mxe:super_events/mxe:super_event[@event_type='tra']/mxe:title[normalize-space(text())]">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'track', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="text()"/>
            </field>
        </xsl:for-each>

        <!-- Video -->
        <xsl:for-each select="$content/mxe:eve/mxe:documents/mxe:document[@role='video']/mxe:uri[normalize-space(text())]">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'video', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="text()"/>
            </field>
        </xsl:for-each>

        <!-- Paper -->
        <xsl:for-each select="$content/mxe:eve/mxe:documents/mxe:document[@role='paper']/mxe:uri[normalize-space(text())]">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'paper', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="text()"/>
            </field>
        </xsl:for-each>

        <!-- Slides -->
        <xsl:for-each select="$content/mxe:eve/mxe:documents/mxe:document[@role='slides']/mxe:uri[normalize-space(text())]">
            <field>
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($prefix, 'slides', $suffix)"/>
                </xsl:attribute>
                <xsl:value-of select="text()"/>
            </field>
        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>

