<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:dt="http://www.daisy.org/z3986/2005/dtbook/"
                exclude-result-prefixes="dt"
                version="1.0">

    <xsl:output method="xml" indent="no" encoding="UTF-8"/>

    <xsl:template match="/">
        <package xmlns="http://www.idpf.org/2007/opf"
                 version="3.0"
                 unique-identifier="pub-identifier"
                 prefix="scandinavia: http://www.random.url">
            <metadata>
                <dc:identifier id="pub-identifier">
                    <xsl:value-of select="//dt:meta[@name='dtb:uid']/@content"/>
                </dc:identifier>
                <dc:title>
                    <xsl:value-of select="//dt:meta[@name='dc:Title']/@content"/>
                </dc:title>
                <dc:creator>
                    <xsl:value-of select="//dt:meta[@name='dc:Creator'][1]/@content"/>
                </dc:creator>
                <dc:date>
                    <xsl:value-of select="//dt:meta[@name='dc:Date']/@content"/>
                </dc:date>
                <dc:format>
                    <xsl:value-of select="//dt:meta[@name='dc:Format']/@content"/>
                </dc:format>
                <dc:language>
                    <xsl:value-of select="//dt:meta[@name='dc:Language']/@content"/>
                </dc:language>
                <dc:publisher>
                    <xsl:value-of select="//dt:meta[@name='dc:Publisher']/@content"/>
                </dc:publisher>
                <dc:source>
                    <xsl:value-of select="//dt:meta[@name='dc:Source']/@content"/>
                </dc:source>

                <meta property="nordic:guidelines">
                    <xsl:value-of select="//dt:meta[@name='track:Guidelines']/@content"/>
                </meta>
                <meta name="nordic:guidelines">
                    <xsl:attribute name="content">
                        <xsl:value-of select="//dt:meta[@name='track:Guidelines']/@content"/>
                    </xsl:attribute>
                </meta>

                <meta property="nordic:supplier">
                    <xsl:value-of select="//dt:meta[@name='track:Supplier']/@content"/>
                </meta>
                <meta name="nordic:supplier">
                    <xsl:attribute name="content">
                        <xsl:value-of select="//dt:meta[@name='track:Supplier']/@content"/>
                    </xsl:attribute>
                </meta>

                <meta property="dcterms:modified">
                    <xsl:value-of select="//dt:meta[@name='dcterms:modified']/@content"/>
                </meta>
            </metadata>
        </package>
    </xsl:template>
</xsl:stylesheet>
