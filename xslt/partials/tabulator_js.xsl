<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template name="tabulator_js">
        <xsl:param name="clickme" select="true()"></xsl:param>
        <xsl:param name="column_toggle_control_id" as="xs:string" select="''"></xsl:param>
        
        <link
            href="vendor/tabulator-tables/css/tabulator.min.css" rel="stylesheet"></link>
        <link
            href="vendor/tabulator-tables/css/tabulator_bootstrap5.min.css" rel="stylesheet"></link>
        <script
            type="text/javascript" src="vendor/tabulator-tables/js/tabulator.min.js"></script>
        <script
            src="tabulator-js/config.js"></script>
        <script
            src="tabulator-js/utils.js"></script>
        <script>
            var table = new Tabulator("#myTable", config);
            var columnToggleControlId = "<xsl:value-of select="$column_toggle_control_id"/>";

            TabulatorUtils.setupColumnVisibility(table, columnToggleControlId);
            TabulatorUtils.bindDownloadButtons(table);
            
            
            <xsl:if test="$clickme"> table.on("rowClick",
                function(e, row){ var data = row.getData(); var url = `${data["id"]}.html`; window.open(url,
                "_self"); });
            </xsl:if>

                        TabulatorUtils.bindCounters(table);
        </script>
    </xsl:template>
</xsl:stylesheet>