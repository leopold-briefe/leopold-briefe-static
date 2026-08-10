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
    <xsl:import href="./partials/typesense_libs.xsl"/>
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Kalender'"/>
        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"/>
                </xsl:call-template>
                <link rel="stylesheet" href="vendor/calendar-component/calendar.css"/>
                <link rel="stylesheet" href="css/calendar.css"/>
            </head>

            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>
                <main class="flex-shrink-0 flex-grow-1">
                    <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb"
                        class="ps-5 p-3">
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
                    <div class="container-fluid d-md-px-5 pb-4">
                        <h1 class="display-5 text-center">
                            <xsl:value-of select="$doc_title"/>
                        </h1>
                        <h2 class="text-center">
                            Kalendarische Übersicht der erfassten, erwähnten und verzeichneten Briefe
                        </h2>
                        <p class="lead pt-3 text-center">
                            Hier vielleicht ein kurzer Erklärtext zu den "erfasst", "erwähnt" und "vezeichnet".
                        </p>
                        <div id="calendar-container">
                            <acdh-ch-calendar>
                                <div class="calendar-menu">
                                    <label class="p2 text-center fs-2">
                                        <span>Jahr</span>
                                    </label>
                                    <acdh-ch-calendar-year-picker data-variant="sparse"></acdh-ch-calendar-year-picker>
                                    <span class="p2 text-center fs-2">Legende</span>
                                    <acdh-ch-calendar-legend>
                                        <ul class="list-unstyled">
                                            <li>
                                                <span class="dot erfasst"></span>
                                                <span class="legend-item">Erfasster Brief</span>
                                            </li>
                                            <li>
                                                <span class="dot verzeichent"></span>
                                                <span class="legend-item">Verzeichneter Brief</span>
                                            </li>
                                            <li>
                                                <span class="dot mehrere_briefe"></span>
                                                <span class="legend-item">Mehrere Briefe (erfasst, erwähnt, verzeichnet)</span>
                                            </li>
                                        </ul>
                                    </acdh-ch-calendar-legend>
                                </div>
                                <div class="calendar-container text-center">
                                    <acdh-ch-calendar-year data-variant="sparse"/>
                                    <div class="mt-4">
                                        <span>Korrespondenz des Jahres herunterladen: </span>
                                        <button type="button" id="year-pdf-download-btn" class="btn btn-link me-2">
                                            <i class="bi bi-filetype-pdf me-1"></i>
                                            <span>PDF</span>
                                        </button>
                                    </div>
                                </div>
                                
                            </acdh-ch-calendar>
                        </div>
                    </div>
                </main>
                <xsl:call-template name="html_footer"/>
                <script type="module" src="js/calendar.js"/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
