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
        <xsl:variable name="doc_title" select="'Briefverzeichnis'"/>
        <xsl:variable name="link" select="'toc.html'"/>
        <xsl:variable name="boolean-filter">
            <xsl:text>{"values":{"":"All","True":"Yes","False":"No"}}</xsl:text>
        </xsl:variable>
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
                    <div class="container-fluid">
                        <h1 class="display-5 text-center"><xsl:value-of select="$doc_title"/></h1>
                        <div class="text-center p-1"><span id="counter1"></span> von <span id="counter2"></span> Originalbriefe</div>
                        <table id="myTable">
                            <thead>
                                <tr>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-formatter="html" tabulator-download="false" tabulator-minWidth="350">Emfpänger</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-visible="false" tabulator-download="true">receiver_</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-formatter="html" tabulator-download="false" tabulator-maxWidth="170">gesendet</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-maxWidth="150">empfangen</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-visible="false" tabulator-download="true">date_</th>
                                    <th scope="col" tabulator-headerFilter="list" tabulator-maxWidth="170">
                                        <xsl:attribute name="tabulator-headerFilterParams">
                                            <xsl:text>{"values":{"":"Alle"</xsl:text>
                                            <xsl:for-each select="sort(distinct-values(.//tei:correspAction[@type='sent']/tei:placeName[@key]/text()))">
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="concat('&quot;', ., '&quot;:&quot;', ., '&quot;')"/>
                                            </xsl:for-each>
                                            <xsl:text>}}</xsl:text>
                                        </xsl:attribute>
                                        Ort (von)
                                    </th>
                                    <th scope="col" tabulator-headerFilter="list" tabulator-maxWidth="170">
                                        <xsl:attribute name="tabulator-headerFilterParams">
                                            <xsl:text>{"values":{"":"Alle"</xsl:text>
                                            <xsl:for-each select="sort(distinct-values(.//tei:correspAction[@type='received']/tei:placeName[@key]/text()))">
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="concat('&quot;', ., '&quot;:&quot;', ., '&quot;')"/>
                                            </xsl:for-each>
                                            <xsl:text>}}</xsl:text>
                                        </xsl:attribute>
                                        Ort (nach)
                                    </th>
                                    <th scope="col" tabulator-headerFilter="list" tabulator-maxWidth="170">
                                        <xsl:attribute name="tabulator-headerFilterParams">
                                            <xsl:text>{"values":{"":"Alle"</xsl:text>
                                            <xsl:for-each select="distinct-values(.//tei:noteGrp[@type='metadata']/tei:note[@type='kind']/text())">
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="concat('&quot;', ., '&quot;:&quot;', ., '&quot;')"/>
                                            </xsl:for-each>
                                            <xsl:text>}}</xsl:text>
                                        </xsl:attribute>
                                        Art
                                    </th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-maxWidth="110">Sprache</th>
                                    <th scope="col" tabulator-headerFilter="list" >
                                        <xsl:attribute name="tabulator-headerFilterParams" >
                                            <xsl:text>{"values":{"":"Alle"</xsl:text>
                                            <xsl:for-each select="distinct-values(.//tei:noteGrp[@type='metadata']/tei:note[@type='archiv']/text())">
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="concat('&quot;', ., '&quot;:&quot;', ., '&quot;')"/>
                                            </xsl:for-each>
                                            <xsl:text>}}</xsl:text>
                                        </xsl:attribute>
                                        Archiv
                                    </th>
                                    <th scope="col" tabulator-headerFilter="input" >Signatur</th>
                                    <th
                                        scope="col"
                                        tabulator-formatter="tickCross"
                                        tabulator-headerFilter="list"
                                        tabulator-maxWidth="90">
                                        <xsl:attribute name="tabulator-headerFilterParams">
                                            <xsl:text>{"values":{"":"Alle","1":"Ja","0":"Nein"}}</xsl:text>
                                        </xsl:attribute>
                                        Text
                                    </th>
                                    <th
                                        scope="col"
                                        tabulator-formatter="tickCross"
                                        tabulator-headerFilter="list"
                                        tabulator-maxWidth="80">
                                        <xsl:attribute name="tabulator-headerFilterParams">
                                            <xsl:text>{"values":{"":"Alle","1":"Ja","0":"Nein"}}</xsl:text>
                                        </xsl:attribute>
                                        Bild
                                    </th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-maxWidth="100">ID</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each
                                    select=".//tei:correspDesc[@xml:id]">
                                    <xsl:sort select=".//tei:note[@type='not_before']/text()"></xsl:sort>
                                    <xsl:variable name="docId">
                                        <xsl:value-of select="@xml:id"/>
                                    </xsl:variable>
                                    <xsl:variable name="sortDate" select=".//tei:note[@type='not_before']/text()"/>
                                    <xsl:variable name="sent" as="node()">
                                        <xsl:value-of select="./tei:correspAction[@type='sent']/tei:date"/>
                                    </xsl:variable>
                                    <xsl:variable name="received" as="node()">
                                        <xsl:value-of select="./tei:correspAction[@type='received']/tei:date"/>
                                    </xsl:variable>
                                    <xsl:variable name="linkToDoc" select="./tei:noteGrp[@type='metadata']/tei:note[@type='file_exists']/text() = '1' or ./tei:noteGrp[@type='metadata']/tei:note[@type='images_on_share']/text() = '1'"/>
                                    <tr>
                                        <td>
                                            <xsl:choose>
                                                <xsl:when test="$linkToDoc">
                                                    <a href="{$docId || '.html'}">
                                                        <xsl:value-of select="string-join(.//tei:correspAction[@type='received']/tei:persName/text(), ', ')"/>
                                                    </a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="string-join(.//tei:correspAction[@type='received']/tei:persName/text(), ', ')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </td>
                                        <td>
                                            <xsl:value-of select="string-join(.//tei:correspAction[@type='received']/tei:persName/text(), ', ')"/>
                                        </td>
                                        <td>
                                            <span data-sortkey="{$sortDate}">
                                                <xsl:value-of select="./tei:correspAction[@type='sent']/tei:date"/>
                                            </span>
                                        </td>
                                        <td>
                                            <xsl:value-of select="$received"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="$sortDate"/>
                                        </td>
                                        
                                        <td>
                                            <xsl:value-of select="./tei:correspAction[@type='sent']//tei:placeName[1]/text()"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="./tei:correspAction[@type='received']//tei:placeName[1]/text()"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="./tei:noteGrp[@type='metadata']/tei:note[@type='kind']/text()"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="./tei:noteGrp[@type='metadata']/tei:note[@type='main_language']/text()"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="./tei:noteGrp[@type='metadata']/tei:note[@type='archiv']/text()"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="./tei:noteGrp[@type='metadata']/tei:note[@type='collection']/text()"/>, <xsl:value-of select="./tei:noteGrp[@type='metadata']/tei:note[@type='signatur']/text()"/>
                                        </td>
                                        <td>                                           
                                            <xsl:value-of select="./tei:noteGrp[@type='metadata']/tei:note[@type='file_exists']/text()"/>
                                        </td>
                                        <td>                                           
                                            <xsl:value-of select="./tei:noteGrp[@type='metadata']/tei:note[@type='images_on_share']/text()"/>
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
                <xsl:call-template name="tabulator_js">
                    <xsl:with-param name="clickme" select="false()"></xsl:with-param>
                </xsl:call-template>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>