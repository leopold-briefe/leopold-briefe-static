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
    <xsl:import href="./partials/tabulator_column_toggle.xsl"/>
    <xsl:import href="./partials/blockquote.xsl"/>
    <xsl:import href="./partials/zotero.xsl"/>
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>


    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Erwähnte (verzeichnete) Briefe'"/>
        <xsl:variable name="link" select="'mentioned-letters-toc.html'"/>
        <xsl:variable name="column_toggle_control_id" as="xs:string" select="'toc-column-toggle'"/>
        <xsl:variable name="initial_visible_columns" as="xs:string*"
            select="('gesendet', 'ort_nach', 'addressee_worked_out', 'id')"/>
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
                        <div class="text-center p-1"><span id="counter1"></span> von <span id="counter2"></span> Dokumenten</div>
                        <xsl:call-template name="tabulator_column_toggle">
                            <xsl:with-param name="control_id" select="$column_toggle_control_id"/>
                            <xsl:with-param name="button_label" select="'Spalten anzeigen'"/>
                            <xsl:with-param name="initial_visible_columns" select="$initial_visible_columns"/>
                        </xsl:call-template>
                        <table id="myTable">
                            <thead>
                                <tr>
                                    <th scope="col" tabulator-field="gesendet" tabulator-headerFilter="input" tabulator-hozAlign="right">Absendedatum</th>
                                    <th scope="col" tabulator-field="ort_nach" tabulator-headerFilter="list">
                                        <xsl:attribute name="tabulator-headerFilterParams">
                                            <xsl:text>{"values":{"":"Alle"</xsl:text>
                                            <xsl:for-each select="sort(distinct-values(.//tei:correspAction[@type='received']/tei:placeName[@key and @type='destination']/text()))">
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="concat('&quot;', ., '&quot;:&quot;', ., '&quot;')"/>
                                            </xsl:for-each>
                                            <xsl:text>}}</xsl:text>
                                        </xsl:attribute>
                                        Zielland oder Zielort
                                    </th>
                                    <th scope="col" tabulator-field="addressee_worked_out" tabulator-headerFilter="list">
                                        <xsl:attribute name="tabulator-headerFilterParams">
                                            <xsl:text>{"values":{"":"Alle"</xsl:text>
                                            <xsl:for-each select="sort(distinct-values(.//tei:correspAction[@type='received']/tei:persName[@type='addressee_worked_out']/text()))">
                                                <xsl:text>,</xsl:text>
                                                <xsl:value-of select="concat('&quot;', ., '&quot;:&quot;', ., '&quot;')"/>
                                            </xsl:for-each>
                                            <xsl:text>}}</xsl:text>
                                        </xsl:attribute>
                                        Emfpänger (erschlossen)
                                    </th>
                                    <th scope="col" tabulator-field="comment" tabulator-headerFilter="input" tabulator-hozAlign="left">Kommentar</th>
                                    <th scope="col" tabulator-field="original_letter" tabulator-headerFilter="input" tabulator-formatter="html" tabulator-download="false">Überlieferter Brief</th>
                                    <th scope="col" tabulator-field="original_letter_download_" tabulator-visible="false" tabulator-download="true">Überlieferter Brief_</th>
                                    <th scope="col" tabulator-field="id" tabulator-headerFilter="input">ID</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each
                                    select=".//tei:correspDesc[@xml:id]">
                                    <xsl:sort select=".//tei:note[@type='not_before']/text()"></xsl:sort>
                                    <xsl:variable name="docId">
                                        <xsl:value-of select="@xml:id"/>
                                    </xsl:variable>
                                    <xsl:variable name="sortDate" select="./tei:correspAction[@type='sent']/tei:date"/>
                                    <tr>
                                        <td>
                                            <xsl:value-of select="$sortDate"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="./tei:correspAction[@type='received']//tei:placeName[@type='destination']/text()"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="./tei:correspAction[@type='received']//tei:persName[@type='addressee_worked_out']/text()"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="./tei:note[@type='anmerkung']/text()"/>
                                        </td>
                                        <td>
                                            <xsl:choose>
                                                <xsl:when test="./@corresp">
                                                    <xsl:variable name="linkToOriginal">
                                                        <xsl:value-of select="replace(./@corresp, '#', '')"/>
                                                    </xsl:variable>
                                                    <a href="{$linkToOriginal}.html"><xsl:value-of select="./@corresp"/></a>
                                                </xsl:when>
                                                <xsl:otherwise/>
                                            </xsl:choose>
                                        </td>
                                        <td>
                                            <xsl:value-of select="./@corresp"/>
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
                    <xsl:with-param name="column_toggle_control_id" select="$column_toggle_control_id"></xsl:with-param>
                </xsl:call-template>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>