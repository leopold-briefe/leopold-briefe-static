<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="xsl tei xs">
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/tabulator_dl_buttons.xsl"/>
    <xsl:import href="./partials/tabulator_js.xsl"/>
    <xsl:import href="./partials/blockquote.xsl"/>
    <xsl:import href="./partials/zotero.xsl"/>
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>


    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Originalbriefe'"/>
        <xsl:variable name="link" select="'toc.html'"/>
        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="zoterMetaTags">
                    <xsl:with-param name="pageId" select="$link"></xsl:with-param>
                    <xsl:with-param name="zoteroTitle" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
            </head>
            
            <body class="d-flex flex-column h-100">
            <xsl:call-template name="nav_bar"/>
                <main class="flex-shrink-0 flex-grow-1">
                    <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb" class="ps-5 p-3">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item">
                                <a href="index.html">
                                    <xsl:value-of select="$project_short_title"/>
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">
                                <xsl:value-of select="$doc_title"/>
                            </li>
                        </ol>
                    </nav>
                    <div class="container">
                        <h1 class="display-5 text-center"><xsl:value-of select="$doc_title"/></h1>
                        <div class="text-center p-1"><span id="counter1"></span> von <span id="counter2"></span> Originalbriefe</div>
                        <table id="myTable">
                            <thead>
                                <tr>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-formatter="html" tabulator-download="false" tabulator-minWidth="350">Emfpänger</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-visible="false" tabulator-download="true">receiver_</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-formatter="html" tabulator-download="false">Datum</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-visible="false" tabulator-download="true">date_</th>
                                    <th scope="col" tabulator-headerFilter="input" >Ort</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-formatter="html">Abschrift, Kopie, Konzept</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-maxWidth="110">Sprache</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-maxWidth="100">ID</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each
                                    select="collection('../data/editions?select=*.xml')//tei:TEI[.//tei:origin/tei:term/text() eq 'Original']">
                                    <xsl:sort select="//tei:history/tei:origin/tei:origDate/@when-iso"></xsl:sort>
                                    <xsl:variable name="docId">
                                        <xsl:value-of select="replace(@xml:id, '.xml', '')"/>
                                    </xsl:variable>
                                    <tr>
                                        <td>
                                            <a href="{$docId || '.html'}">
                                                <xsl:value-of select="string-join(.//tei:correspAction[@type='received']/tei:persName/text(), ', ')"/>
                                            </a>
                                        </td>
                                        <td>
                                            <xsl:value-of select="string-join(.//tei:correspAction[@type='received']/tei:persName/text(), ', ')"/>
                                        </td>
                                        <td>
                                            <span data-isodate="{//tei:history/tei:origin/tei:origDate/@when-iso}">
                                                <xsl:value-of select=".//tei:correspAction[1]/tei:date/text()"/>
                                            </span>
                                        </td>
                                        <td>
                                            <xsl:value-of select="//tei:history/tei:origin/tei:origDate/@when-iso"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select=".//tei:correspAction[@type='received']//tei:placeName[1]/text()"/>
                                        </td>
                                        <td>
                                            <ul>
                                                <xsl:for-each select=".//tei:sourceDesc/tei:listRelation/tei:relation">
                                                    <li>
                                                        <a href="{replace(./@active, '.xml', '.html')}"><xsl:value-of select="./@n"/></a>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                        </td>
                                        <td>
                                            <xsl:value-of select=".//tei:language/@ident"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="$docId"/>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                        <xsl:call-template name="tabulator_dl_buttons"/>
                        <div class="text-center p-4">
                            <xsl:call-template name="blockquote">
                                <xsl:with-param name="pageId" select="'toc.html'"/>
                            </xsl:call-template>
                        </div>
                    </div>
                </main>
                <xsl:call-template name="html_footer"/>
                <xsl:call-template name="tabulator_js"/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>