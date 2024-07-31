<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:dt="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                exclude-result-prefixes="dt">

    <xsl:output method="xml" indent="no" encoding="UTF-8"/>

    <xsl:param name="level1_id"/>

    <!-- Root template -->
    <xsl:template match="/">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#10;</xsl:text>
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
            <xsl:apply-templates select="//dt:level1[@id=$level1_id]"/>
        </html>
    </xsl:template>

    <xsl:template match="dt:level1[@id='level1_1']">
        <body epub:type="{@class}" id="{@cover_id}">
            <xsl:apply-templates select="dt:prodnote" mode="in_cover"/>
        </body>
    </xsl:template>

    <xsl:template match="dt:level1">
        <!--    <xsl:template match="dt:level1[not(@id='level1_1')]">-->
        <xsl:variable name="parent_name" select="name(..)"/>
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="@class">
                    <xsl:value-of select="concat($parent_name, ' ', @class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$parent_name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <body id="{@body_id}" epub:type="{$type}" class="nonstandardpagination">
            <xsl:choose>
                <xsl:when test="@original_class='footnotes'">
                    <h1 id="{@epub_id}">
                        <xsl:text>Kapitel</xsl:text>
                    </h1>
                    <section epub:type="footnotes" class="footnotes" id="{@footnote_id}">
                        <ol>
                            <xsl:apply-templates/>
                        </ol>
                    </section>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </body>
    </xsl:template>

    <xsl:template match="dt:level2">
        <section id="{@epub_id}">
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="dt:level3">
        <section id="{@epub_id}">
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="dt:level4">
        <section id="{@epub_id}">
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <!--***** NOTES ETC *****-->
    <xsl:template match="dt:note">
        <li class="notebody" epub:type="footnote" id="{@note_id}">
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="dt:noteref">
        <xsl:variable name="identifier" select="//dt:meta[@name='dc:Identifier']/@content"/>

        <xsl:variable name="level1_ancestor" select="ancestor::*[name() = 'level1'][1]"/>
        <xsl:variable name="level1_class" select="$level1_ancestor/@class"/>
        <xsl:variable name="level1_name">
            <xsl:choose>
                <xsl:when test="$level1_class">
                    <xsl:value-of select="$level1_class"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name($level1_ancestor)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="file_index">
            <xsl:variable name="number" select="substring-after($level1_id, '_')"/>
            <xsl:value-of select="format-number($number+1, '000')"/>
        </xsl:variable>

        <xsl:variable name="parent_href" select="concat($identifier, '-', $file_index, '-', $level1_name, '.xhtml#')"/>

        <a id="{@epub_id}" epub:type="{name()}" title="" class="{name()}" href="{$parent_href}{@note_id}">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>

    <xsl:template match="dt:prodnote" mode="in_cover">
        <section class="{@class}" id="{@cover_id}">
            <xsl:if test="@class = 'frontcover'">
                <h2 id="frontcover-heading">
                    <xsl:value-of select="//dt:meta[@name='dc:Title']/@content"/>
                </h2>
            </xsl:if>
            <aside epub:type="z3998:production" class="prodnote" id="{@epub_id}">
                <xsl:apply-templates/>
            </aside>
        </section>
    </xsl:template>

    <xsl:template match="dt:prodnote" mode="in_imggroup">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="dt:prodnote">
        <aside epub:type="z3998:production" class="prodnote" id="{@epub_id}">
            <xsl:apply-templates/>
        </aside>
    </xsl:template>

    <xsl:template match="dt:blockquote">
        <blockquote>
            <xsl:apply-templates/>
        </blockquote>
    </xsl:template>

    <xsl:template match="dt:sidebar">
        <aside epub:type="sidebar" class="sidebar" id="{@epub_id}">
            <xsl:apply-templates/>
        </aside>
    </xsl:template>

    <!--***** IMAGE *****-->
    <xsl:template match="dt:imggroup">
        <figure class="image">
            <xsl:apply-templates select="dt:img"/>
            <xsl:choose>
                <xsl:when test="ancestor::dt:level1[@id='level1_1'] or ancestor::dt:level1[@id='level1_4']">
                    <xsl:apply-templates select="dt:caption" mode="in_imggroup"/>
                    <xsl:apply-templates select="dt:prodnote" mode="in_imggroup"/>
                </xsl:when>
                <xsl:when test="ancestor::dt:level1[@id='level1_2']">
                    <figcaption>
                        <p>
                            <xsl:apply-templates select="dt:caption" mode="in_imggroup"/>
                            <xsl:apply-templates select="dt:prodnote" mode="in_imggroup"/>
                        </p>
                    </figcaption>
                </xsl:when>
                <xsl:otherwise>
                    <figcaption>
                        <p>
                            <xsl:apply-templates select="dt:caption" mode="in_imggroup"/>
                            <br/>
                            <br/>
                            <xsl:apply-templates select="dt:prodnote" mode="in_imggroup"/>
                        </p>
                    </figcaption>
                </xsl:otherwise>
            </xsl:choose>
        </figure>
    </xsl:template>

    <xsl:template match="dt:img">
        <img src="images/{@img_id}" alt="{@alt}" id="{@epub_id}"/>
    </xsl:template>

    <xsl:template match="dt:caption" mode="in_imggroup">
        <xsl:apply-templates/>
    </xsl:template>

    <!--***** TEXT *****-->
    <xsl:template match="dt:h1">
        <h1>
            <xsl:if test="@class = 'title fulltitle'">
                <xsl:attribute name="class">
                    <xsl:text>title</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="epub:type">
                    <xsl:text>fulltitle</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="id">
                <xsl:value-of select="@epub_id"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </h1>
    </xsl:template>

    <xsl:template match="dt:h2">
        <h2 id="{@epub_id}">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="dt:h3">
        <h3 id="{@epub_id}">
            <xsl:apply-templates/>
        </h3>
    </xsl:template>

    <xsl:template match="dt:h4">
        <h4 id="{@epub_id}">
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <xsl:template match="dt:p">
        <xsl:choose>
            <xsl:when test="ancestor::dt:imggroup">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <p id="{@epub_id}">
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dt:strong">
        <strong>
            <xsl:apply-templates/>
        </strong>
    </xsl:template>

    <xsl:template match="dt:u">
        <u>
            <xsl:apply-templates/>
        </u>
    </xsl:template>

    <xsl:template match="dt:em">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>

    <!--***** LIST *****-->
    <xsl:template match="dt:list">
        <ol>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="@type = 'pl'">plain</xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="dt:li"/>
        </ol>
    </xsl:template>

    <xsl:template match="dt:li">
        <li id="{@epub_id}">
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="dt:lic">
        <span class="lic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="dt:dl">
        <dl id="{@epub_id}">
            <xsl:apply-templates/>
        </dl>
    </xsl:template>

    <xsl:template match="dt:dt">
        <dt id="{@epub_id}">
            <xsl:apply-templates/>
        </dt>
    </xsl:template>

    <xsl:template match="dt:dd">
        <dd id="{@epub_id}">
            <xsl:apply-templates/>
        </dd>
    </xsl:template>

    <!--***** TABLE *****-->
    <xsl:template match="dt:table">
        <table id="{@epub_id}">
            <xsl:apply-templates select="dt:caption"/>
            <tbody id="{@epub_id}">
                <xsl:apply-templates select="dt:tr"/>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template match="dt:caption">
        <caption id="{@epub_id}">
            <xsl:apply-templates/>
        </caption>
    </xsl:template>

    <xsl:template match="dt:tr">
        <tr id="{@epub_id}">
            <xsl:apply-templates select="dt:th | dt:td"/>
        </tr>
    </xsl:template>

    <xsl:template match="dt:th">
        <th id="{@epub_id}">
            <xsl:apply-templates/>
        </th>
    </xsl:template>

    <xsl:template match="dt:td">
        <td id="{@epub_id}">
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <!--***** PAGENUM *****-->
    <xsl:template match="dt:pagenum">
        <xsl:choose>
            <xsl:when
                    test="count(preceding-sibling::*[not(self::dt:em or self::dt:strong or self::dt:u or self::dt:noteref or self::dt:pagenum)]) + count(following-sibling::*[not(self::dt:em or self::dt:strong or self::dt:u or self::dt:noteref or self::dt:pagenum)]) = 0">
                <span epub:type="pagebreak">
                    <xsl:attribute name="class">
                        <xsl:choose>
                            <xsl:when test="ancestor::dt:frontmatter">page-front</xsl:when>
                            <xsl:otherwise>page-special</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="id">
                        <xsl:value-of select="@epub_id"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <div epub:type="pagebreak">
                    <xsl:attribute name="class">
                        <xsl:choose>
                            <xsl:when test="ancestor::dt:frontmatter">page-front</xsl:when>
                            <xsl:otherwise>page-special</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="id">
                        <xsl:value-of select="@epub_id"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
