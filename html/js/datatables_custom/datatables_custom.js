
const columns = [];

document.querySelectorAll('#myTable thead th').forEach((th) => {
    const label = th.textContent.trim();

    columns.push({
        data: th.textContent.trim().toLowerCase(),
        visible: th.dataset.dtVisible !== 'false',
        render: (data, type) => {
        if (type !== 'display') return data;
        if (String(data) === '1') return '<i class="bi bi-check-lg text-success"></i>';
        if (String(data) === '0') return '<i class="bi bi-x-lg text-danger"></i>';
        return data;
    },
        columnControl: [
            {
                target: 0,
                content: ['orderStatus']
            },
            {
                target: 1,
                content: [
                    {
                        extend: 'search',
                        placeholder: label
                    }
                ]
            }
        ]
    });
});

const table = new DataTable('#myTable', {
    columnDefs: [
        // Disable column visibility control for the first column
		{
			target: 0,
			className: 'always-visible'
		},
	],
    layout: {
        topStart: {
            buttons: [{
					extend: 'colvis',
					columns: ':not(.always-visible)',
				}]
        },
        topEnd: {
            buttons: [
                {
                    extend: 'collection',
                    text: 'Export',
                    buttons: ['copy', 'csv', 'print']
                }
            ]
        },
        bottomStart: 'pageLength',
        bottomEnd: 'paging'
    },
    language: {
        url: 'js/datatables_custom/de-DE.json',
    },
    initComplete: function () {
        updateInfo(this.api());
        // ColumnControl builds its search-row DOM asynchronously after initComplete fires
        setTimeout(labelSearchLogicSelects, 0);
    },

    columns: columns,

    ordering: {
        indicators: false
    }
});

table.on('draw', function () {
    updateInfo(table);
});

table.on('click', 'tbody tr', function (event) {
    if (event.target.closest('a')) {
        return;
    }

    const link = this.querySelector('a');

    if (link) {
        link.click();
    }
});

function updateInfo(table) {
    const info = table.page.info();

    document.querySelector('#custom-info-box').textContent =
        `${info.recordsDisplay} von ${info.recordsTotal} Einträgen`;
}

// ColumnControl renders the search-logic <select> without an accessible name
function labelSearchLogicSelects() {
    document.querySelectorAll('#myTable thead th').forEach((th, index) => {
        const label = th.querySelector('.dt-column-title').textContent.trim();
        const select = document.querySelectorAll('#myTable thead span.dtcc select.form-select')[index];

        if (label && select) {
            select.setAttribute('aria-label', `Suchmodus für ${label}`);
        }
    });
}