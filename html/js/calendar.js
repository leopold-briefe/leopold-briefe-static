import { register } from "../vendor/calendar-component/calendar.js";
import de from "../vendor/calendar-component/i18n/de.js";

const EVENT_MODAL_ID = "calendarEventModal";

register({});
// register()

let currentYear = 1696;
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

function formatEventValue(value) {
    if (value === null) {
        return "null";
    }

    if (value instanceof Date) {
        return value.toISOString();
    }

    if (Array.isArray(value) || typeof value === "object") {
        return JSON.stringify(value, null, 2);
    }

    return String(value);
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
    if (events.length === 0) {
        return "<p class=\"mb-0\">Keine Ereignisse gefunden.</p>";
    }

    return events
        .map((calendarEvent, index) => {
            const entries = Object.entries(calendarEvent);
            const props = entries
                .map(([key, value]) => {
                    return `
                        <tr>
                            <th class="w-25 text-nowrap" scope="row">${escapeHtml(key)}</th>
                            <td><pre class="mb-0">${escapeHtml(formatEventValue(value))}</pre></td>
                        </tr>
                    `;
                })
                .join("");

            return `
                <section class="mb-4">
                    <h2 class="h6">Ereignis ${index + 1}</h2>
                    <div class="table-responsive">
                        <table class="table table-sm align-middle mb-0">
                            <tbody>${props}</tbody>
                        </table>
                    </div>
                </section>
            `;
        })
        .join("");
}

function onEventClick(event) {
    const { date, events } = event.detail;
    const modalElement = ensureEventModal();
    const title = modalElement.querySelector(".modal-title");
    const body = modalElement.querySelector(".modal-body");

    if (title != null) {
        title.textContent = `${date} mit ${events.length} Ereignissen`;
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