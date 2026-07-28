// Shared helpers for Tabulator tables initialized from XSL templates.
window.TabulatorUtils = (function () {
    function refreshTableLayout(table) {
        window.requestAnimationFrame(function () {
            table.redraw(true);
        });
    }

    function getInitialVisibleColumns(toggleContainer) {
        if (!toggleContainer) {
            return [];
        }

        var configuredFields = toggleContainer.dataset.initialVisibleColumns || "";
        return configuredFields
            .split(",")
            .map(function (field) {
                return field.trim();
            })
            .filter(function (field) {
                return field.length > 0;
            });
    }

    function getUniqueColumns(table) {
        var columnsByKey = new Map();

        table.getColumns().forEach(function (column, index) {
            var field = column.getField();
            var key = field ? ("field:" + field) : ("index:" + index);

            if (columnsByKey.has(key)) {
                return;
            }

            columnsByKey.set(key, column);
        });

        return Array.from(columnsByKey.values());
    }

    function isVisibilityMenuField(field) {
        return !!field && !field.endsWith("_");
    }

    function applyInitialColumnVisibility(table, toggleContainer) {
        var initialVisibleColumns = getInitialVisibleColumns(toggleContainer);

        if (initialVisibleColumns.length === 0) {
            return;
        }

        var visibleFieldSet = new Set(initialVisibleColumns);

        getUniqueColumns(table).forEach(function (column) {
            var field = column.getField();

            if (!field) {
                return;
            }

            if (visibleFieldSet.has(field)) {
                column.show();
            } else {
                column.hide();
            }
        });

        refreshTableLayout(table);
    }

    function renderColumnVisibilityControls(table, toggleContainer) {
        if (!toggleContainer) {
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

        getUniqueColumns(table).forEach(function (column) {
            var field = column.getField();

            if (!isVisibilityMenuField(field)) {
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

            checkbox.addEventListener("change", function () {
                var targetColumn = table.getColumn(field);

                if (!targetColumn) {
                    return;
                }

                if (checkbox.checked) {
                    targetColumn.show();
                } else {
                    targetColumn.hide();
                }

                refreshTableLayout(table);
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

    function parseHeaderFilterParams(table) {
        var parsedHeaderFilterUpdates = [];

        getUniqueColumns(table).forEach(function (column) {
            var definition = column.getDefinition();

            if (typeof definition.headerFilterParams === "string") {
                try {
                    var parsedHeaderFilterParams = JSON.parse(definition.headerFilterParams);
                    parsedHeaderFilterUpdates.push(
                        table.updateColumnDefinition(column, { headerFilterParams: parsedHeaderFilterParams })
                    );
                } catch (error) {
                    // Keep original value if it is not valid JSON.
                }
            }
        });

        return Promise.all(parsedHeaderFilterUpdates).catch(function () {
            // Non-fatal: keep table usable even if a column update fails.
        });
    }

    function setupColumnVisibility(table, columnToggleControlId) {
        table.on("tableBuilt", function () {
            parseHeaderFilterParams(table).finally(function () {
                var toggleContainer = null;

                if (columnToggleControlId) {
                    toggleContainer = document.getElementById(columnToggleControlId);
                }

                applyInitialColumnVisibility(table, toggleContainer);
                renderColumnVisibilityControls(table, toggleContainer);

                table.on("columnVisibilityChanged", function () {
                    refreshTableLayout(table);
                });
            });
        });
    }

    function bindDownloadButtons(table) {
        var csv = document.getElementById("download-csv");
        var json = document.getElementById("download-json");
        var html = document.getElementById("download-html");

        if (csv) {
            csv.addEventListener("click", function () {
                table.download("csv", "data.csv");
            });
        }

        if (json) {
            json.addEventListener("click", function () {
                table.download("json", "data.json");
            });
        }

        if (html) {
            html.addEventListener("click", function () {
                table.download("html", "data.html", { style: true });
            });
        }
    }

    function bindCounters(table) {
        table.on("dataLoaded", function (data) {
            var counter1 = document.getElementById("counter1");
            var counter2 = document.getElementById("counter2");

            if (counter1) {
                counter1.innerHTML = "" + data.length;
            }

            if (counter2) {
                counter2.innerHTML = "" + data.length;
            }
        });

        table.on("dataFiltered", function (filters, data) {
            var counter1 = document.getElementById("counter1");

            if (counter1) {
                counter1.innerHTML = "" + data.length;
            }
        });
    }

    return {
        setupColumnVisibility: setupColumnVisibility,
        bindDownloadButtons: bindDownloadButtons,
        bindCounters: bindCounters
    };
})();
