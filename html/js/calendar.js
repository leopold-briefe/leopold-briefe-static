import { register } from "../vendor/calendar-component/calendar.js";
import de from "../vendor/calendar-component/i18n/de.js";

const EVENT_MODAL_ID = "calendarEventModal";

register({});
// register()

let currentYear = 1657;
function createCalendar(i18n, events, onEventClick) {
    const calendar = document.querySelector("acdh-ch-calendar");

    if (i18n != null) {
        /** Optionally set locale, defaults to english. */
        calendar.setI18n(i18n);
    }

    /** Optionally, set the initial year. */
    calendar.setData({ events, currentYear: currentYear });
    // calendar.setData({ events });

    calendar.addEventListener("calendar-event-click", onEventClick);
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

function normalizeEventLabel(value) {
    return String(value)
        .replace(/^Leopold I\.\s+/u, "")
        .replace(/\s+am\s+\d{4}-\d{2}-\d{2}/u, "")
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
    const renderEventList = (kind) => events
        .filter((calendarEvent) => calendarEvent.kind === kind)
        .map((calendarEvent) => `<li>${renderEventLabel(calendarEvent)}</li>`)
        .join("");

    const recordedItems = renderEventList("verzeichnet/erwähnt");
    const originalItems = renderEventList("erfasst");
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
    const recordedColumn = recordedItems
        ? `<section class="col-12 col-md-6">
        <h2 class="fs-6">verzeichnete Briefe:</h2>
        <ul>${recordedItems}</ul>
    </section>`
        : "";

    const originalColumn = originalItems
        ? `<section class="col-12 col-md-6">
        <h2 class="fs-6">überlieferte Originale:</h2>
        <ul>${originalItems}</ul>
    </section>`
        : "";

    const eventSections = recordedColumn || originalColumn
        ? `<div class="row">${recordedColumn}${originalColumn}</div>`
        : "";
    return `
        ${descriptionParagraph}
        ${eventSections}
    `;
}

function onEventClick(event) {
    const { date, events } = event.detail;
    const formattedDate = new Intl.DateTimeFormat("de-DE", {
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
    return events.map((event) => {
        return { ...event, date: new Date(event.date) };
    });
}

try {
    const events = await request("js-data/calendarData.json");
    createCalendar(de, events, onEventClick);
    console.log("Successfully created calendar.");
} catch (error) {
    console.error("Failed to create calendar.\n", String(error));
}