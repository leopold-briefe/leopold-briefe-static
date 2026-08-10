import { getDateRange } from './get-date-range.ts';
import { I18n } from './i18n/types.ts';

export interface CalendarEvent {
    date: Date;
    kind: string;
    label: string;
}
export interface CalendarData {
    events: Array<CalendarEvent>;
    eventsByDate: Map<number, Map<string, Array<CalendarEvent>>>;
    startYear: number | null;
    endYear: number | null;
}
export declare class Calendar extends HTMLElement {
    data: CalendarData;
    currentYear: number | null;
    i18n: {
        months: string[];
    };
    picker: CalendarYearSelect | null;
    calendar: CalendarYear | null;
    constructor();
    connectedCallback(): void;
    setData(data: CalendarData & {
        currentYear?: number;
    }): void;
    update(): void;
    setI18n(i18n: I18n): void;
}
export interface CalendarYearPickerData {
    startYear: number;
    endYear: number;
    currentYear: number;
    eventsByDate: Map<number, Map<string, Array<CalendarEvent>>>;
}
export declare class CalendarYearSelect extends HTMLElement {
    data: CalendarYearPickerData | null;
    /** Display full range of years, or only years with events. */
    variant: "full" | "sparse";
    constructor();
    connectedCallback(): void;
    setData(data: CalendarYearPickerData): void;
    update(): void;
}
export declare class CalendarYearRadioGroup extends HTMLElement {
    data: CalendarYearPickerData | null;
    /** Display full range of years, or only years with events. */
    variant: "full" | "sparse";
    id: string;
    constructor();
    connectedCallback(): void;
    setData(data: CalendarYearPickerData): void;
    update(): void;
}
export interface CalendarYearData {
    currentYear: number;
    eventsByDate: Map<string, Array<CalendarEvent>> | null;
}
export declare class CalendarYear extends HTMLElement {
    data: CalendarYearData | null;
    i18n: {
        months: string[];
    };
    constructor();
    connectedCallback(): void;
    setData(data: CalendarYearData): void;
    update(): void;
    setI18n(i18n: I18n): void;
}
interface CalendarRegisterOptions {
    picker?: "radio-group" | "select";
}
export declare function register(options?: CalendarRegisterOptions): void;
export { getDateRange };
