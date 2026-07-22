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
        <script>
            var table = new Tabulator("#myTable", config);
            var columnToggleControlId = "<xsl:value-of select="$column_toggle_control_id"/>";

            function refreshTableLayout() {
            window.requestAnimationFrame(function(){
            table.redraw(true);
            });
            }

            function getInitialVisibleColumns(toggleContainer) {
            if(!toggleContainer){
            return [];
            }

            var configuredFields = toggleContainer.dataset.initialVisibleColumns || "";
            return configuredFields.split(",").map(function(field){
            return field.trim();
            }).filter(function(field){
            return field.length > 0;
            });
            }

            function getUniqueFieldColumns() {
            var columnsByKey = new Map();

            table.getColumns().forEach(function(column, index){
            var field = column.getField();
            var key = field ? ("field:" + field) : ("index:" + index);

            if(columnsByKey.has(key)){
            return;
            }

            columnsByKey.set(key, column);
            });

            return Array.from(columnsByKey.values());
            }

            function isVisibilityMenuField(field) {
            return !field.endsWith("_");
            }

            function applyInitialColumnVisibility(toggleContainer) {
            var initialVisibleColumns = getInitialVisibleColumns(toggleContainer);

            if(initialVisibleColumns.length === 0){
            return;
            }

            var visibleFieldSet = new Set(initialVisibleColumns);

            getUniqueFieldColumns().forEach(function(column){
            var field = column.getField();

            if(!field){
            return;
            }

            if(visibleFieldSet.has(field)){
            column.show();
            } else {
            column.hide();
            }
            });

            refreshTableLayout();
            }

            function renderColumnVisibilityControls(toggleContainer) {
            if(!toggleContainer){
            return;
            }

            toggleContainer.innerHTML = "";

            var dropdown = document.createElement("div");
            dropdown.className = "dropdown";

            var button = document.createElement("button");
            button.className = "btn btn-outline-secondary btn-sm dropdown-toggle";
            button.type = "button";
            button.setAttribute("data-bs-toggle", "dropdown");
            button.setAttribute("aria-expanded", "false");
            button.textContent = toggleContainer.dataset.buttonLabel || "Spalten";

            var menu = document.createElement("div");
            menu.className = "dropdown-menu p-3 shadow";
            menu.style.maxHeight = "420px";
            menu.style.overflowY = "auto";
            menu.style.minWidth = "280px";

            getUniqueFieldColumns().forEach(function(column){
            var field = column.getField();

            if(!field){
            return;
            }

            if(!isVisibilityMenuField(field)){
            return;
            }

            var definition = column.getDefinition();
            var labelText = definition.title || field;
            var item = document.createElement("label");
            item.className = "dropdown-item d-flex align-items-center gap-2";
            item.style.cursor = "pointer";

            var checkbox = document.createElement("input");
            checkbox.type = "checkbox";
            checkbox.className = "form-check-input m-0";
            checkbox.checked = column.isVisible();

            checkbox.addEventListener("change", function(){
            var targetColumn = table.getColumn(field);

            if(!targetColumn){
            return;
            }

            if(checkbox.checked){
            targetColumn.show();
            } else {
            targetColumn.hide();
            }

            refreshTableLayout();
            });

            var text = document.createElement("span");
            text.textContent = labelText;

            item.appendChild(checkbox);
            item.appendChild(text);
            menu.appendChild(item);
            });

            dropdown.appendChild(button);
            dropdown.appendChild(menu);
            toggleContainer.appendChild(dropdown);
            }

            // Tabulator's HTML importer keeps complex header params as strings.
            // Update affected columns after build so list filters get their values.
            table.on("tableBuilt", function(){
            var parsedHeaderFilterUpdates = [];

            getUniqueFieldColumns().forEach(function(column){
            var definition = column.getDefinition();

            if(typeof definition.headerFilterParams === "string"){
            try {
            var parsedHeaderFilterParams = JSON.parse(definition.headerFilterParams);
            parsedHeaderFilterUpdates.push(
            table.updateColumnDefinition(column, {headerFilterParams: parsedHeaderFilterParams})
            );
            } catch (error) {
            // Keep original value if it is not valid JSON.
            }
            }
            });

            Promise.all(parsedHeaderFilterUpdates).catch(function(){
            // Non-fatal: keep table usable even if a column update fails.
            }).finally(function(){
            var toggleContainer = null;
            if(columnToggleControlId){
            toggleContainer = document.getElementById(columnToggleControlId);
            }

            applyInitialColumnVisibility(toggleContainer);
            renderColumnVisibilityControls(toggleContainer);

            table.on("columnVisibilityChanged", function(){
            refreshTableLayout();
            });
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