import { createHash, timingSafeEqual } from "node:crypto";

export const supportedEventTypes = [
  "INITIAL_PURCHASE", "RENEWAL", "CANCELLATION", "EXPIRATION",
  "BILLING_ISSUE", "PRODUCT_CHANGE", "REFUND",
] as const;

export type RevenueCatEventType = (typeof supportedEventTypes)[number];

export interface RevenueCatEvent {
  id?: string | null;
  type: string;
  product_id?: string | null;
  app_user_id?: string | null;
  store?: string | null;
  country_code?: string | null;
  price?: number | null;
  price_in_purchased_currency?: number | null;
  /** Accepted for integrations that normalize monetary values to micros. */
  price_in_purchased_currency_micros?: number | null;
  currency?: string | null;
  environment?: string | null;
  event_timestamp_ms?: number | null;
}

export interface RevenueCatWebhookPayload {
  api_version?: string;
  event?: RevenueCatEvent;
}

export interface SlackBlock {
  type: "header" | "section" | "divider";
  text?: { type: "plain_text" | "mrkdwn"; text: string; emoji?: boolean };
}

export interface SlackWebhookPayload {
  text: string;
  blocks: SlackBlock[];
}

const eventIcons: Record<RevenueCatEventType, string> = {
  INITIAL_PURCHASE: "🟢", RENEWAL: "🔄", CANCELLATION: "❌",
  EXPIRATION: "⌛", BILLING_ISSUE: "⚠️", PRODUCT_CHANGE: "🔁", REFUND: "💸",
};

const importantEventTypes: ReadonlySet<RevenueCatEventType> = new Set([
  "INITIAL_PURCHASE", "REFUND",
]);

const productNames: Readonly<Record<string, string>> = {
  jlpt_master_pro_monthly_v2: "Pro Monthly V2",
};

export function isSupportedEvent(type: string): type is RevenueCatEventType {
  return (supportedEventTypes as readonly string[]).includes(type);
}

/** Compares hashes so timing does not reveal the configured secret's length. */
export function isValidAuthorization(received: string | undefined, expected: string): boolean {
  if (!received || !expected) return false;
  const digest = (value: string): Buffer => createHash("sha256").update(value, "utf8").digest();
  return timingSafeEqual(digest(received), digest(expected));
}

export function deduplicationKey(eventId: string): string {
  return createHash("sha256").update(eventId, "utf8").digest("hex");
}

function slackEscape(value: unknown): string {
  if (value === undefined || value === null || value === "") return "N/A";
  return String(value).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

export function eventPrice(event: RevenueCatEvent): number | undefined {
  const micros = event.price_in_purchased_currency_micros;
  if (typeof micros === "number" && Number.isFinite(micros)) return micros / 1_000_000;
  const price = event.price_in_purchased_currency ?? event.price;
  return typeof price === "number" && Number.isFinite(price) ? price : undefined;
}

export function formatPrice(amount: number | undefined, currency: string | null | undefined): string {
  if (amount === undefined) return "N/A";
  const code = currency?.toUpperCase();
  if (!code) return String(amount);
  try {
    const formatted = new Intl.NumberFormat("en-US", {
      style: "currency", currency: code, currencyDisplay: "symbol",
    }).format(amount);
    if (code === "JPY") return formatted.replace("¥", "¥");
    if (code === "USD") return formatted.replace("$", "US$");
    return formatted;
  } catch {
    return `${amount} ${slackEscape(code)}`;
  }
}

export function formatEventTime(timestampMs: number | null | undefined): string {
  if (typeof timestampMs !== "number" || !Number.isFinite(timestampMs)) return "N/A";
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Tokyo", year: "numeric", month: "2-digit", day: "2-digit",
    hour: "2-digit", minute: "2-digit", hourCycle: "h23",
  }).formatToParts(new Date(timestampMs));
  const get = (type: Intl.DateTimeFormatPartTypes): string =>
    parts.find((part) => part.type === type)?.value ?? "";
  return `${get("year")}-${get("month")}-${get("day")} ${get("hour")}:${get("minute")} JST`;
}

export function buildSlackPayload(
  event: RevenueCatEvent & { type: RevenueCatEventType },
): SlackWebhookPayload {
  const mention = importantEventTypes.has(event.type) ? "<!channel>\n" : "";
  const product = event.product_id ? productNames[event.product_id] ?? event.product_id : undefined;
  const details = [
    `${mention}*${eventIcons[event.type]} ${event.type}*`,
    "━━━━━━━━━━━━━━",
    "*App:* JLPT Master",
    `*Product:* ${slackEscape(product)}`,
    `*Price:* ${formatPrice(eventPrice(event), event.currency)}`,
    `*Currency:* ${slackEscape(event.currency?.toUpperCase())}`,
    `*Country:* ${slackEscape(event.country_code)}`,
    `*Store:* ${slackEscape(event.store)}`,
    `*User:* ${slackEscape(event.app_user_id)}`,
    `*Environment:* ${slackEscape(event.environment)}`,
    `*Time:* ${formatEventTime(event.event_timestamp_ms)}`,
  ].join("\n");

  return {
    text: `${importantEventTypes.has(event.type) ? "<!channel> " : ""}${eventIcons[event.type]} ${event.type} - JLPT Master`,
    blocks: [
      { type: "header", text: { type: "plain_text", text: "💰 New Revenue", emoji: true } },
      { type: "section", text: { type: "mrkdwn", text: details } },
    ],
  };
}
