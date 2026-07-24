<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template name="blockquote">
        <xsl:param name="pageId" select="''"></xsl:param>
        <xsl:param name="customUrl" select="$base_url"></xsl:param>
        <xsl:param name="docTitle" select="''"></xsl:param>
        <xsl:variable name="fullUrl" select="concat($customUrl, $pageId)"/>
        <div>
            <h2 class="fs-4">Zitiervorschlag</h2>
            <blockquote class="blockquote">
                <p>
                    <xsl:value-of select="$docTitle"/><xsl:value-of select="$project_title"/>, hg. v. Petr Maťa, technische Umsetzung durch Peter Andorfer, Wien 2026. URL: <a href="{$fullUrl}"><xsl:value-of select="$fullUrl"/></a> (abgerufen am <span id="currentDate"/>).
                </p>
            </blockquote>
        </div>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                var el = document.getElementById("currentDate");
                if (!el) return;

                var formatted = new Date().toLocaleDateString("de-DE", {
                    day: "numeric",
                    month: "long",
                    year: "numeric"
                });

                el.textContent = formatted;
            });
        </script>
    </xsl:template>
</xsl:stylesheet>