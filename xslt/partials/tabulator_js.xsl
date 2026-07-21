<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template name="tabulator_js">
        <xsl:param name="clickme" select="true()"></xsl:param>
        
        <link
            href="vendor/tabulator-tables/css/tabulator.min.css" rel="stylesheet"></link>
        <link
            href="vendor/tabulator-tables/css/tabulator_bootstrap5.min.css" rel="stylesheet"></link>
        <script
            type="text/javascript" src="vendor/tabulator-tables/js/tabulator.min.js"></script>
        <script
            src="tabulator-js/config.js"></script>
        <script>
            var table = new Tabulator("#myTable", config);

            // Tabulator's HTML importer keeps complex header params as strings.
            // Update affected columns after build so list filters get their values.
            table.on("tableBuilt", function(){
            var parsedHeaderFilterUpdates = [];

            table.getColumns().forEach(function(column){
            var definition = column.getDefinition();

            if(typeof definition.headerFilterParams === "string"){
            try {
            var parsedHeaderFilterParams = JSON.parse(definition.headerFilterParams);
            parsedHeaderFilterUpdates.push(
            table.updateColumnDefinition(definition.field, {headerFilterParams: parsedHeaderFilterParams})
            );
            } catch (error) {
            // Keep original value if it is not valid JSON.
            }
            }
            });

            Promise.all(parsedHeaderFilterUpdates).catch(function(){
            // Non-fatal: keep table usable even if a column update fails.
            });
            });

            //trigger download of data.csv file
            document.getElementById("download-csv").addEventListener("click", function(){
            table.download("csv", "data.csv");
            });
            
            //trigger download of data.json file
            document.getElementById("download-json").addEventListener("click", function(){
            table.download("json", "data.json");
            });
            
            //trigger download of data.html file
            document.getElementById("download-html").addEventListener("click", function(){
            table.download("html", "data.html", {style:true});
            });
            
            
            <xsl:if test="$clickme"> table.on("rowClick",
                function(e, row){ var data = row.getData(); var url = `${data["id"]}.html`; window.open(url,
                "_self"); });
            </xsl:if>

            
            
            
            table.on("dataLoaded", function (data) {
            var el = document.getElementById("counter1");
            el.innerHTML = `${data.length}`;
            var el = document.getElementById("counter2");
            el.innerHTML = `${data.length}`;
            });
            
            table.on("dataFiltered", function (filters, data) {
            var el = document.getElementById("counter1");
            el.innerHTML = `${data.length}`;
            }); 
        </script>
    </xsl:template>
</xsl:stylesheet>