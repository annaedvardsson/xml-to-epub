<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:dt="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                exclude-result-prefixes="dt">

    <xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="no"/>

    <xsl:param name="level1_id"/>

    <!-- Root template -->
    <xsl:template match="/">
        <html epub:prefix="z3998: http://www.daisy.org/z3998/2012/vocab/structure/#"
              lang="{//dt:meta[@name='dc:Language']/@content}" xml:lang="{//dt:meta[@name='dc:Language']/@content}">
            <head>
                <meta charset="UTF-8"/>
                <title>
                    <xsl:value-of select="//dt:meta[@name='dc:Title']/@content"/>
                </title>
                <meta name="dc:identifier" content="{//dt:meta[@name='dc:Identifier']/@content}"/>
                <meta name="viewport" content="width=device-width"/>
                <link href="css/epub.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>
                <nav epub:type="toc">
                    <h1>Innehållsförteckning</h1>
                    <ol class="list-style-type-none">
                        <xsl:apply-templates select="//dt:level1"/>
                    </ol>
                </nav>
                <nav epub:type="page-list">
                    <h1>Sidlista</h1>
                    <ol class="list-style-type-none">
                        <xsl:apply-templates select="//dt:pagenum"/>
                    </ol>
                </nav>
            </body>
        </html>
    </xsl:template>

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

        <li>
            <a href="{concat($parent_href, @cover_id)}">
                <xsl:text>Omslagssida</xsl:text>
            </a>
            <xsl:if test="dt:prodnote">
                <ol class="list-style-type-none">
                    <xsl:apply-templates select="dt:prodnote">
                        <xsl:with-param name="parent_href" select="$parent_href"/>
                    </xsl:apply-templates>
                </ol>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="dt:level1">
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

        <li>
            <a href="{concat($parent_href, @body_id)}">
<!--            <a href="{concat($parent_href, @epub_id)}">-->
                <xsl:choose>
                    <xsl:when test="dt:h1">
                        <xsl:value-of select="dt:h1"/>
                    </xsl:when>
                    <xsl:when test="@original_class='footnotes'">
                        <xsl:text>Kapitel</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>Namnlös</xsl:otherwise>
                </xsl:choose>
            </a>

            <xsl:if test="dt:level2">
                <ol class="list-style-type-none">
                    <xsl:apply-templates select="dt:level2">
                        <xsl:with-param name="parent_href" select="$parent_href"/>
                    </xsl:apply-templates>
                </ol>
            </xsl:if>

            <xsl:if test="dt:note">
                <ol class="list-style-type-none">
                    <li>
                        <a href="{concat($parent_href, @footnote_id)}">
                            <xsl:text>Namnlös</xsl:text>
                        </a>
                    </li>
                </ol>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="dt:level2">
        <xsl:param name="parent_href"/>
        <li>
            <a href="{concat($parent_href, @epub_id)}">
                <xsl:value-of select="dt:h2"/>
            </a>
            <xsl:if test="dt:level3">
                <ol class="list-style-type-none">
                    <xsl:apply-templates select="dt:level3">
                        <xsl:with-param name="parent_href" select="$parent_href"/>
                    </xsl:apply-templates>
                </ol>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="dt:level3">
        <xsl:param name="parent_href"/>
        <li>
            <a href="{concat($parent_href, @epub_id)}">
                <xsl:value-of select="dt:h3"/>
            </a>
            <xsl:if test="dt:level4">
                <ol class="list-style-type-none">
                    <xsl:apply-templates select="dt:level4">
                        <xsl:with-param name="parent_href" select="$parent_href"/>
                    </xsl:apply-templates>
                </ol>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="dt:level4">
        <xsl:param name="parent_href"/>
        <li>
            <a href="{concat($parent_href, @epub_id)}">
                <xsl:value-of select="dt:h4"/>
            </a>
        </li>
    </xsl:template>

    <xsl:template match="dt:prodnote">
        <xsl:param name="parent_href"/>
        <li>
            <a href="{concat($parent_href, @cover_id)}">
                <xsl:choose>
                    <xsl:when test="@id='prodnote_1'">
                        <xsl:value-of select="//dt:meta[@name='dc:Title']/@content"/>
                    </xsl:when>
                    <xsl:otherwise>Baksida</xsl:otherwise>
                </xsl:choose>
            </a>
        </li>
    </xsl:template>

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

        <li>
            <a href="{concat($parent_href, @epub_id)}">
                <xsl:value-of select="."/>
            </a>
        </li>
    </xsl:template>

</xsl:stylesheet>
