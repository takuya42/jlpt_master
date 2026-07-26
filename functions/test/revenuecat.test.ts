import assert from "node:assert/strict";
import test from "node:test";
import {
  buildSlackPayload, deduplicationKey, eventPrice, formatEventTime,
  formatPrice, isSupportedEvent, isValidAuthorization,
} from "../src/revenuecat.js";

test("validates the complete Authorization header", () => {
  assert.equal(isValidAuthorization("Bearer secret", "Bearer secret"), true);
  assert.equal(isValidAuthorization("Bearer wrong", "Bearer secret"), false);
  assert.equal(isValidAuthorization(undefined, "Bearer secret"), false);
});

test("identifies notification event types", () => {
  assert.equal(isSupportedEvent("RENEWAL"), true);
  assert.equal(isSupportedEvent("TRANSFER"), false);
});

test("formats JST time and localized currency", () => {
  assert.equal(formatEventTime(Date.UTC(2026, 6, 26, 2, 30)), "2026-07-26 11:30 JST");
  assert.equal(formatPrice(980, "JPY"), "¥980");
  assert.equal(formatPrice(6.99, "USD"), "US$6.99");
  assert.equal(eventPrice({ type: "RENEWAL", price_in_purchased_currency_micros: 6_990_000 }), 6.99);
});

test("builds Block Kit and mentions channel for initial purchases", () => {
  const payload = buildSlackPayload({
    id: "evt-1", type: "INITIAL_PURCHASE", product_id: "jlpt_master_pro_monthly_v2",
    app_user_id: "abc123", store: "APP_STORE", country_code: "JP",
    price_in_purchased_currency: 980, currency: "JPY", environment: "PRODUCTION",
    event_timestamp_ms: Date.UTC(2026, 6, 26, 2, 30),
  });
  assert.equal(payload.blocks[0].type, "header");
  assert.match(payload.blocks[0].text?.text ?? "", /New Revenue/);
  assert.match(payload.blocks[1].text?.text ?? "", /<!channel>/);
  assert.match(payload.blocks[1].text?.text ?? "", /Pro Monthly V2/);
  assert.match(payload.blocks[1].text?.text ?? "", /\*Price:\* ¥980/);
  assert.match(payload.blocks[1].text?.text ?? "", /2026-07-26 11:30 JST/);
});

test("does not mention channel for non-important events", () => {
  const payload = buildSlackPayload({ type: "RENEWAL" });
  assert.doesNotMatch(JSON.stringify(payload), /<!channel>/);
});

test("creates safe stable Firestore keys from RevenueCat IDs", () => {
  assert.equal(deduplicationKey("event/with/slashes"), deduplicationKey("event/with/slashes"));
  assert.match(deduplicationKey("event/with/slashes"), /^[a-f0-9]{64}$/);
});
