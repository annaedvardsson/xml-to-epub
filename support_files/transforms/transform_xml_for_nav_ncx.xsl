<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dt="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns="http://www.daisy.org/z3986/2005/ncx/"
                exclude-result-prefixes="dt"
                version="1.0">

    <xsl:output method="xml" indent="no" encoding="UTF-8"/>

    <!-- Root template -->
    <xsl:template match="/">
        <xsl:variable name="dtb_depth">
            <xsl:call-template name="find-max-level">
                <xsl:with-param name="levels" select="//node()[starts-with(name(), 'level')]"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="max_page_number">
            <xsl:for-each select="//dt:pagenum">
                <xsl:if test="position() = last()">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <ncx version="2005-1" xml:lang="{/dt:dtbook/@xml:lang}">
<!--        <ncx version="{/dt:dtbook/@version}" xml:lang="{/dt:dtbook/@xml:lang}">-->
            <head>
                <meta name="dtb:uid" content="{//dt:meta[@name='dtb:uid']/@content}"/>
                <meta name="dtb:depth" content="{$dtb_depth}"/>
                <meta name="dtb:generator" content="XYZ Generator"/>
                <meta name="dtb:totalPageCount" content="{count(//dt:pagenum)}"/>
                <meta name="dtb:maxPageNumber" content="{$max_page_number}"/>
            </head>
            <docTitle>
                <text>
                    <xsl:value-of select="//dt:meta[@name='dc:Title']/@content"/>
                </text>
            </docTitle>
            <navMap>
                <navLabel>
                    <text>Innehållsförteckning</text>
                </navLabel>
                <xsl:apply-templates select="//dt:level1"/>
            </navMap>
            <pageList>
                <navLabel>
                    <text>Sidlista</text>
                </navLabel>
                <xsl:apply-templates select="//dt:pagenum"/>
            </pageList>
        </ncx>
    </xsl:template>

    <!-- Template for level1_1 (cover) -->
    <xsl:template match="dt:level1[@id='level1_1']">
        <xsl:variable name="identifier" select="//dt:meta[@name='dc:Identifier']/@content"/>
        <xsl:variable name="parent_name" select="name(..)"/>
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="@class">
                    <xsl:value-of select="@class"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$parent_name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="file_index">
            <xsl:variable name="number" select="substring-after(@id, '_')"/>
            <xsl:value-of select="format-number($number, '000')"/>
        </xsl:variable>
        <xsl:variable name="parent_href" select="concat($identifier, '-', $file_index, '-', $class, '.xhtml#')"/>

        <navPoint id="{concat('navPoint-', @ncx_id)}" playOrder="{@ncx_id}">
            <navLabel>
                <text>Omslagssida</text>
            </navLabel>
            <content src="{concat($parent_href, @cover_id)}"/>
            <xsl:if test="dt:prodnote">
                <xsl:apply-templates select="dt:prodnote">
                    <xsl:with-param name="parent_href" select="$parent_href"/>
                </xsl:apply-templates>
            </xsl:if>
        </navPoint>
    </xsl:template>

    <!-- Template for all other level1 -->
    <xsl:template match="dt:level1[not(@id='level1_1')]">
        <xsl:variable name="identifier" select="//dt:meta[@name='dc:Identifier']/@content"/>
        <xsl:variable name="parent_name" select="name(..)"/>
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="@class">
                    <xsl:value-of select="@class"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$parent_name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="file_index">
            <xsl:variable name="number" select="substring-after(@id, '_')"/>
            <xsl:value-of select="format-number($number, '000')"/>
        </xsl:variable>
        <xsl:variable name="parent_href" select="concat($identifier, '-', $file_index, '-', $class, '.xhtml#')"/>

        <navPoint id="{concat('navPoint-', @ncx_id)}" playOrder="{@ncx_id}">
            <navLabel>
                <text>
                    <xsl:choose>
                        <xsl:when test="dt:h1">
                            <xsl:value-of select="dt:h1"/>
                        </xsl:when>
                        <xsl:when test="@original_class='footnotes'">
                            <xsl:text>Kapitel</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>Namnlös</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </text>
            </navLabel>
            <content src="{concat($parent_href, @body_id)}"/>
<!--            <content src="{concat($parent_href, @epub_id)}"/>-->
            <xsl:apply-templates select="dt:level2 | dt:note[position() = 1]">
                <xsl:with-param name="parent_href" select="$parent_href"/>
            </xsl:apply-templates>
        </navPoint>
    </xsl:template>

    <!-- Template for level2 -->
    <xsl:template match="dt:level2">
        <xsl:param name="parent_href"/>
        <navPoint id="{concat('navPoint-', @ncx_id)}" playOrder="{@ncx_id}">
            <navLabel>
                <text>
                    <xsl:choose>
                        <xsl:when test="dt:h2">
                            <xsl:value-of select="dt:h2"/>
                        </xsl:when>
                        <xsl:otherwise>Namnlös</xsl:otherwise>
                    </xsl:choose>
                </text>
            </navLabel>
            <content src="{concat($parent_href, @epub_id)}"/>
            <xsl:apply-templates select="dt:level3">
                <xsl:with-param name="parent_href" select="$parent_href"/>
            </xsl:apply-templates>
        </navPoint>
    </xsl:template>

    <!-- Template for level3 -->
    <xsl:template match="dt:level3">
        <xsl:param name="parent_href"/>
        <navPoint id="{concat('navPoint-', @ncx_id)}" playOrder="{@ncx_id}">
            <navLabel>
                <text>
                    <xsl:choose>
                        <xsl:when test="dt:h3">
                            <xsl:value-of select="dt:h3"/>
                        </xsl:when>
                        <xsl:otherwise>Namnlös</xsl:otherwise>
                    </xsl:choose>
                </text>
            </navLabel>
            <content src="{concat($parent_href, @epub_id)}"/>
            <xsl:apply-templates select="dt:level4">
                <xsl:with-param name="parent_href" select="$parent_href"/>
            </xsl:apply-templates>
        </navPoint>
    </xsl:template>

    <!-- Template for level4 -->
    <xsl:template match="dt:level4">
        <xsl:param name="parent_href"/>
        <navPoint id="{concat('navPoint-', @ncx_id)}" playOrder="{@ncx_id}">
            <navLabel>
                <text>
                    <xsl:choose>
                        <xsl:when test="dt:h4">
                            <xsl:value-of select="dt:h4"/>
                        </xsl:when>
                        <xsl:otherwise>Namnlös</xsl:otherwise>
                    </xsl:choose>
                </text>
            </navLabel>
            <content src="{concat($parent_href, @epub_id)}"/>
        </navPoint>
    </xsl:template>

    <!-- Template for prodnote -->
    <xsl:template match="dt:prodnote">
        <xsl:param name="parent_href"/>
        <navPoint id="{concat('navPoint-', @ncx_id)}" playOrder="{@ncx_id}">
            <navLabel>
                <xsl:choose>
                    <xsl:when test="@id='prodnote_1'">
                        <text><xsl:value-of select="//dt:meta[@name='dc:Title']/@content"/></text>
                    </xsl:when>
                    <xsl:otherwise>
                        <text>Baksida</text>
                    </xsl:otherwise>
                </xsl:choose>
            </navLabel>
            <content src="{concat($parent_href, @cover_id)}"/>
        </navPoint>
    </xsl:template>

    <!-- Template for note -->
    <xsl:template match="dt:note">
        <xsl:param name="parent_href"/>
        <navPoint id="{concat('navPoint-', @ncx_id)}" playOrder="{@ncx_id}">
            <navLabel>
                <text>
                    <xsl:choose>
                        <xsl:when test="dt:h2">
                            <xsl:value-of select="dt:h2"/>
                        </xsl:when>
                        <xsl:otherwise>Namnlös</xsl:otherwise>
                    </xsl:choose>
                </text>
            </navLabel>
            <content src="{concat($parent_href, @epub_id)}"/>
        </navPoint>
    </xsl:template>

    <!-- Template for pagenum -->
    <xsl:template match="dt:pagenum">
        <xsl:variable name="identifier" select="//dt:meta[@name='dc:Identifier']/@content"/>

        <xsl:variable name="parent_class" select="ancestor::dt:level1[1]/@class"/>
        <xsl:variable name="ancestor_parent_node_name">
            <xsl:value-of select="name(ancestor::dt:level1[1]/parent::*)"/>
        </xsl:variable>
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="$parent_class">
                    <xsl:value-of select="$parent_class"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$ancestor_parent_node_name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="level1_id" select="ancestor::dt:level1[1]/@id"/>
        <xsl:variable name="number" select="substring-after($level1_id, '_')"/>
        <xsl:variable name="file_index" select="format-number($number, '000')"/>

        <xsl:variable name="parent_href" select="concat($identifier, '-', $file_index, '-', $class, '.xhtml#')"/>

        <xsl:variable name="is_number">
            <xsl:choose>
                <xsl:when test="number(.) = number(.)">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <pageTarget id="{concat('pageTarget-', @ncx_id)}" playOrder="{@ncx_id}">
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="$is_number = 'true'">normal</xsl:when>
                    <xsl:otherwise>special</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <navLabel>
                <text>
                    <xsl:value-of select="."/>
                </text>
            </navLabel>
            <content src="{concat($parent_href, @epub_id)}"/>
        </pageTarget>
    </xsl:template>

    <!-- Template to calculate the maximum level number -->
    <xsl:template name="find-max-level">
        <xsl:param name="levels" select="//node()[starts-with(name(), 'level')]"/>
        <xsl:param name="max_level" select="0"/>

        <xsl:choose>
            <xsl:when test="count($levels) = 0">
                <xsl:value-of select="$max_level"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="current_level" select="substring-after(name($levels[1]), 'level')"/>
                <xsl:variable name="new_max_level">
                    <xsl:choose>
                        <xsl:when test="$current_level > $max_level">
                            <xsl:value-of select="$current_level"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$max_level"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="find-max-level">
                    <xsl:with-param name="levels" select="$levels[position() > 1]"/>
                    <xsl:with-param name="max_level" select="$new_max_level"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
