<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0"
    exclude-result-prefixes="xsl tei xs">
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/tabulator_dl_buttons.xsl"/>
    <xsl:import href="./partials/tabulator_js.xsl"/>
    <xsl:import href="./partials/entities.xsl"/>
    <xsl:import href="./partials/blockquote.xsl"/>
    <xsl:import href="./partials/zotero.xsl"/>
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>


    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:titleStmt/tei:title[1]/text()"/>
        </xsl:variable>
        <xsl:variable name="link" select="'listevent.html'"/>
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
                        <div class="text-center p-1"><span id="counter1"></span> von <span id="counter2"></span> einträgen</div>

                        <table id="myTable">
                            <thead>
                                <tr>
                                    <th scope="col" tabulator-field="sorting" tabulator-headerFilter="input" tabulator-formatter="html" tabulator-download="false" tabulator-width="120">Datum</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-minWidth="280" tabulator-formatter="html">Text</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-minWidth="280" tabulator-formatter="html">Orte</th>
                                    <th scope="col" tabulator-headerFilter="input" tabulator-visible="false">ID</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select=".//tei:listEvent[@xml:id='letters']/tei:event[@xml:id]">
                                    <xsl:variable name="id">
                                        <xsl:value-of select="data(@xml:id)"/>
                                    </xsl:variable>
                                    <tr>
                                        <td>
                                            <xsl:value-of select="./tei:label/text()"/>
                                        </td>
                                        <td>
                                            <xsl:apply-templates select="./tei:desc"/>
                                        </td>
                                        <td>
                                            <xsl:for-each select=".//tei:placeName">
                                                <a href="{@key}.html">
                                                    <xsl:value-of select="./text()"/>
                                                </a><xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </td>
                                        <td>
                                            <xsl:value-of select="$id"/>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                        <xsl:call-template name="tabulator_dl_buttons"/>
                        <div class="text-center p-4">
                            <xsl:call-template name="blockquote">
                                <xsl:with-param name="pageId" select="'letter-calendar.html'"/>
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
    <xsl:template match="tei:hi[@rend='del']">
        <del><xsl:apply-templates/></del>
    </xsl:template>
    <xsl:template match="tei:hi[@rend='unclear']">
        <xsl:text>[</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text>
    </xsl:template>
</xsl:stylesheet>