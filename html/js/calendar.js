import { register } from "../vendor/calendar-component/calendar.js";
import de from "../vendor/calendar-component/i18n/de.js";

const EVENT_MODAL_ID = "calendarEventModal";

register({});
// register()

let currentYear = 1657;
let undatedYear = null;
const UNDATED_LABEL = "ohne Jahr";
function createCalendar(i18n, events, onEventClick) {
    const calendar = document.querySelector("acdh-ch-calendar");

    if (i18n != null) {
        /** Optionally set locale, defaults to english. */
        calendar.setI18n(i18n);
    }

    /** Optionally, set the initial year. */
    calendar.setData({ events, currentYear: currentYear });
    // calendar.setData({ events });

    const eventCountsByDate = new Map();
    events.forEach((calendarEvent) => {
        const date = calendarEvent.date.toISOString().slice(0, 10);
        const counts = eventCountsByDate.get(date) ?? new Map();
        counts.set(calendarEvent.kind, (counts.get(calendarEvent.kind) ?? 0) + 1);
        eventCountsByDate.set(date, counts);
    });

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