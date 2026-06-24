<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="xsl tei xs">

    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/one_time_alert.xsl"/>
    <xsl:import href="./partials/blockquote.xsl"/>
    <xsl:import href="./partials/zotero.xsl"/>
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select='"leopold-briefe"'/>
        </xsl:variable>
        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="zoterMetaTags"></xsl:call-template>
            </head>            
            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>
                <main class="flex-shrink-0 flex-grow-1">
                    <xsl:call-template name="one_time_alert"/>
                    <div class="container col-xxl-8 pt-3">
                        <div class="row flex-lg-row align-items-center g-5 py-5">
                            <div class="col-lg-6">
                                <h1 class="lh-base">
                                    <span class="display-6">Eigenhändige</span>
                                    <br />
                                    <span class="display-5">Korrespondenz Kaiser Leopolds I. </span>
                                    <br />
                                    <span class="display-6">Digitale Edition</span>
                                </h1>
                                <p>Herausgegeben von Petr Maťa <br/>Wien 2026–</p>
                                <p class="lead">
                                    Eigenhändige Schreiben Kaiser Leopolds I. (1640‒1705) sind für ihre Unlesbarkeit berüchtigt. Auch deswegen bleibt dieses umfangsmäßig, thematisch sowie bezüglich der Briefpartner im monarchischen Vergleich einzigartige Korpus bislang meist unerschlossen. Diese Plattform führt den viersprachigen, europaweit verstreuten Quellenbestand digital zusammen, um dessen schrittweise Katalogisierung und KI-gestützte Transkription zu ermöglichen.
                                </p>
                                <div class="d-grid gap-2 d-md-flex justify-content-md-start">
                                    <!-- <a href="search.html" type="button" class="btn btn-primary btn-lg px-4 me-md-2">Volltextsuche</a> -->
                                   <a href="toc.html" type="button" class="btn btn-outline-primary btn-lg px-4">Zur Korrespondenz</a>
                                </div>
                            </div>
                            <div class="col-10 col-sm-8 col-lg-6">
                                <figure class="figure">
                                    <img src="images/title-image.jpg" class="d-block mx-lg-auto img-fluid" alt="Kaiser Leopold I. (1640-1705) im Harnisch mit Feldherrnstab." width="400" height="600" loading="lazy"/>
                                    <figcaption class="pt-3 figure-caption"> 	
                                        Kaiser Leopold I. (1640-1705) im Harnisch mit Feldherrnstab, Dreiviertelporträt, <a href="https://commons.wikimedia.org/wiki/File:Benjamin_von_Block_001.jpg">via Wikimedia Commons</a></figcaption>
                                </figure>
                            </div>
                            
                        </div>
                        <div class="text-center p-4">
                            <xsl:call-template name="blockquote"/>
                        </div>
                    </div>
                </main>
                <xsl:call-template name="html_footer"/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>