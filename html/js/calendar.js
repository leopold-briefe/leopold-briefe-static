import { register } from "../vendor/calendar-component/calendar.js";
import de from "../vendor/calendar-component/i18n/de.js";

const EVENT_MODAL_ID = "calendarEventModal";
const KIND_LABELS = {
    "erfasst": "überlieferte Originale",
    "verzeichnet/erwähnt": "verzeichnete und erwähnte Briefe",
};

register({});
// register()

let currentYear = 1657;
let undatedYear = null;
const UNDATED_LABEL = "ohne Jahr";
function createCalendar(i18n, allEvents, onEventClick) {
    const calendar = document.querySelector("acdh-ch-calendar");
    const activeKinds = new Set();
    const activeRecipients = new Set();
    const activeDestinations = new Set();
    const eventCountsByDate = new Map();
    let filteredEventsByYear = new Map();

    function renderFilteredYear() {
        calendar.querySelector("acdh-ch-calendar-year").setData({
            currentYear,
            eventsByDate: filteredEventsByYear.get(currentYear) ?? null,
        });
    }

    function applyFilter() {
        const filtered = allEvents.filter((event) =>
            (activeKinds.size === 0 || activeKinds.has(filterValue(event.kind)))
            && (activeRecipients.size === 0 || activeRecipients.has(filterValue(eventRecipient(event))))
            && (activeDestinations.size === 0 || activeDestinations.has(filterValue(event.destination)))
        );
        eventCountsByDate.clear();
        filteredEventsByYear = new Map();
        filtered.forEach((event) => {
            const date = event.date.toISOString().slice(0, 10);
            const year = event.date.getUTCFullYear();
            if (!filteredEventsByYear.has(year)) filteredEventsByYear.set(year, new Map());
            const eventsByDate = filteredEventsByYear.get(year);
            if (!eventsByDate.has(date)) eventsByDate.set(date, []);
            eventsByDate.get(date).push(event);
            const counts = eventCountsByDate.get(date) ?? new Map();
            counts.set(event.kind, (counts.get(event.kind) ?? 0) + 1);
            eventCountsByDate.set(date, counts);
        });
        renderFilteredYear();
    }
    if (i18n != null) {
        /** Optionally set locale, defaults to english. */
        calendar.setI18n(i18n);
    }

    calendar.setData({ events: allEvents, currentYear });
    currentYear = calendar.currentYear;

    const filterContainer = calendar.querySelector(".calendar-filters");
    createMetadataFilter(filterContainer.querySelector("[data-field='kind']"), allEvents, activeKinds, applyFilter, KIND_LABELS);
    createMetadataFilter(filterContainer.querySelector("[data-field='recipient']"), allEvents, activeRecipients, applyFilter);
    createMetadataFilter(filterContainer.querySelector("[data-field='destination']"), allEvents, activeDestinations, applyFilter);
    applyFilter();

    const updateEventCountBadges = () => {
        calendar.querySelectorAll("acdh-ch-calendar-year button[data-event-kinds]").forEach((button) => {
            const counts = eventCountsByDate.get(button.getAttribute("aria-label"));
            if (counts != null && counts.size > 1) {
                button.dataset.erfasstCount = String(counts.get("erfasst") ?? 0);
                button.dataset.verzeichnetCount = String(counts.get("verzeichnet/erwähnt") ?? 0);
            }
        });
    };

    const relabelUndatedYear = () => {
        const year = String(undatedYear);
        calendar.querySelectorAll("acdh-ch-calendar-year-picker label, acdh-ch-calendar-year-picker option").forEach((element) => {
            const input = element.querySelector?.("input");
            const value = input?.value ?? element.value;
            if (value !== year) return;
            const text = element.querySelector?.("span") ?? element;
            if (text.textContent !== UNDATED_LABEL) text.textContent = UNDATED_LABEL;
        });
    };

    const onMutation = () => {
        relabelUndatedYear();
        updateEventCountBadges();
    };

    onMutation();
    new MutationObserver(onMutation).observe(calendar, { childList: true, subtree: true });

    calendar.addEventListener("calendar-event-click", onEventClick);
    calendar.addEventListener("calendar-year-select", (event) => {
        currentYear = event.detail.year;
        renderFilteredYear();
    });

}

function eventRecipient(event) {
    return filterValue(event.recipient) ?? event.recipient_worked_out;
}

function filterValue(value) {
    return typeof value === "string" && value.trim() ? value.trim() : null;
}

function createMetadataFilter(details, events, selected, onChange, labels = {}) {
    const field = details.dataset.field;
    const counts = new Map();
    events.forEach((event) => {
        const value = filterValue(field === "recipient" ? eventRecipient(event) : event[field]);
        counts.set(value, (counts.get(value) ?? 0) + 1);
    });

    const selectedCount = details.querySelector(".calendar-filter-selected");
    const updateSummary = () => {
        selectedCount.textContent = selected.size ? `(${selected.size})` : "";
    };
    const clear = details.querySelector("button");
    const options = details.querySelector(".calendar-filter-options");
    const displayValue = (value) => value === null ? "Nicht angegeben" : (labels[value] ?? value);
    const values = [...counts.keys()].sort((a, b) => {
        if (a === null) return 1;
        if (b === null) return -1;
        return displayValue(a).localeCompare(displayValue(b), "de");
    });
    values.forEach((value) => {
        const option = document.createElement("label");
        option.className = "calendar-filter-option";
        const checkbox = document.createElement("input");
        checkbox.type = "checkbox";
        const text = document.createElement("span");
        text.textContent = `${displayValue(value)} (${counts.get(value)})`;
        checkbox.addEventListener("change", () => {
            if (checkbox.checked) selected.add(value);
            else selected.delete(value);
            updateSummary();
            onChange();
        });
        option.append(checkbox, text);
        options.append(option);
    });
    const search = details.querySelector("input[type='search']");
    if (search) {
        search.addEventListener("input", () => {
            const query = search.value.trim().toLocaleLowerCase("de");
            options.querySelectorAll("label").forEach((option) => {
                option.hidden = !option.textContent.toLocaleLowerCase("de").includes(query);
            });
        });
    }
    clear.addEventListener("click", () => {
        selected.clear();
        options.querySelectorAll("input").forEach((checkbox) => { checkbox.checked = false; });
        updateSummary();
        onChange();
    });
}

function escapeHtml(value) {
    return String(value)
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll("\"", "&quot;")
        .replaceAll("'", "&#39;");
}

    function formatEventDescription(value) {
        return escapeHtml(value)
        .replaceAll("\\", "")
        .replace(/~~(.*?)~~/gu, '<del>$1</del>')
        .replace(/\*\*(.*?)\*\*/gu, '<strong>$1</strong>')
        // Note: using fst-normal because the em is inside italic text
        .replace(/\*(.*?)\*/gu, '<em class="fst-normal">$1</em>');
    }
// Remove "Leopold I." and the date from event labels
function normalizeEventLabel(value) {
    return String(value)
        .replace(/^Leopold I\.\s+/u, "")
        .replace(/\s+am\s+(?:\d{4}-\d{2}-\d{2}|\d{1,2}\.\s+\p{L}+\s+\d{4})/u, "")
        .trim();
}

function renderEventLabel(calendarEvent) {
    const label = escapeHtml(normalizeEventLabel(calendarEvent.label ?? ""));
    if (calendarEvent.link === true && typeof calendarEvent.id === "string") {
        const href = `${encodeURIComponent(calendarEvent.id)}.html`;
        return `<a href="${href}">${label}</a>`;
    }

    return label;
}

function ensureEventModal() {
    let modalElement = document.getElementById(EVENT_MODAL_ID);
    if (modalElement != null) {
        return modalElement;
    }

    modalElement = document.createElement("div");
    modalElement.id = EVENT_MODAL_ID;
    modalElement.className = "modal fade";
    modalElement.tabIndex = -1;
    modalElement.setAttribute("aria-labelledby", `${EVENT_MODAL_ID}Label`);
    modalElement.setAttribute("aria-hidden", "true");
    modalElement.innerHTML = `
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 class="modal-title fs-5" id="${EVENT_MODAL_ID}Label">Ereignisdetails</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body"></div>
            </div>
        </div>
    `;

    document.body.append(modalElement);
    return modalElement;
}

function renderEventDetails(events) {
    const recorded = events.filter((calendarEvent) => calendarEvent.kind === "verzeichnet/erwähnt");
    const originals = events.filter((calendarEvent) => calendarEvent.kind === "erfasst");
    const distinctDescriptions = [...new Set(
        events
            .map((calendarEvent) => calendarEvent.description)
            .filter((description) => typeof description === "string" && description.trim() !== ""),
    )];

    const descriptionText = distinctDescriptions.length > 0
        ? distinctDescriptions.map(formatEventDescription).join(" | ")
        : false;
    const descriptionParagraph = descriptionText !== false
        ? `<p class="lead fst-italic">${descriptionText}</p>`
        : "";
    // Pair each recorded letter with its original (via original_letter_id);
    // an original shared by several recorded letters appears on the first one only.
    const usedOriginals = new Set();
    const rows = recorded.map((recordedEvent) => {
        const original = originals.find((candidate) => (
            candidate.id === recordedEvent.original_letter_id && !usedOriginals.has(candidate)
        ));
        if (original !== undefined) {
            usedOriginals.add(original);
        }
        return { recorded: recordedEvent, original };
    });
    originals
        .filter((original) => !usedOriginals.has(original))
        .forEach((original) => rows.push({ recorded: undefined, original }));

    const hasRecorded = recorded.length > 0;
    const hasOriginals = originals.length > 0;
    const workedOutRecipient = (row) => (
        row.recorded?.recipient_worked_out ?? row.original?.recipient_worked_out ?? ""
    );
    const hasWorkedOut = rows.some((row) => workedOutRecipient(row) !== "");
    const renderCell = (calendarEvent) => `<td>${calendarEvent ? renderEventLabel(calendarEvent) : ""}</td>`;

    let eventSections = "";
    if (rows.length > 0) {
        const head = [
            hasRecorded ? '<th scope="col">verzeichnete Briefe</th>' : "",
            hasOriginals ? '<th scope="col">überlieferte Originale</th>' : "",
            hasWorkedOut ? '<th scope="col">identifizierte Empfänger</th>' : "",
        ].join("");
        const body = rows.map((row) => `<tr>${
            hasRecorded ? renderCell(row.recorded) : ""
        }${
            hasOriginals ? renderCell(row.original) : ""
        }${
            hasWorkedOut ? `<td>${escapeHtml(workedOutRecipient(row))}</td>` : ""
        }</tr>`).join("");
        eventSections = `<table class="table table-sm">
        <thead><tr>${head}</tr></thead>
        <tbody>${body}</tbody>
    </table>`;
    }
    return `
        ${descriptionParagraph}
        ${eventSections}
    `;
}

function onEventClick(event) {
    const { date, events } = event.detail;
    const formattedDate = date.getUTCFullYear() === undatedYear
        ? UNDATED_LABEL
        : new Intl.DateTimeFormat("de-DE", {
            weekday: "long",
            day: "numeric",
            month: "long",
            year: "numeric",
        }).format(date);
    const modalElement = ensureEventModal();
    const title = modalElement.querySelector(".modal-title");
    const body = modalElement.querySelector(".modal-body");

    if (title != null) {
        title.textContent = `${formattedDate}`;
    }

    if (body != null) {
        body.innerHTML = renderEventDetails(events);
    }

    const modal = new bootstrap.Modal(modalElement);
    modal.show();
}

async function request(url) {
    const response = await fetch(url);
    const events = await response.json();
    const dated = events
        .filter((event) => event.date)
        .map((event) => ({ ...event, date: new Date(event.date) }))
        .filter((event) => !Number.isNaN(event.date.getTime()));

    // The calendar needs real dates, so undated events go into a dummy year after the last real one.
    undatedYear = Math.max(...dated.map((event) => event.date.getUTCFullYear())) + 1;
    const undated = events
        .filter((event) => !event.date)
        .map((event) => ({ ...event, date: new Date(Date.UTC(undatedYear, 0, 1)) }));

    return [...dated, ...undated];
}

try {
    const events = await request("js-data/calendarData.json");
    createCalendar(de, events, onEventClick);
    console.log("Successfully created calendar.");
} catch (error) {
    console.error("Failed to create calendar.\n", String(error));
}