<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:template name="tabulator_column_toggle">
        <xsl:param name="control_id" as="xs:string" select="'tabulator-column-toggle'"/>
        <xsl:param name="button_label" as="xs:string" select="'Spalten'"/>
        <xsl:param name="initial_visible_columns" as="xs:string*" select="()"/>

        <div class="d-flex justify-content-end py-2">
            <div id="{$control_id}"
                class="tabulator-column-toggle"
                data-button-label="{$button_label}"
                data-initial-visible-columns="{string-join($initial_visible_columns, ',')}">
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>