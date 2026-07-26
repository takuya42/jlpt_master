import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { defineSecret } from "firebase-functions/params";
import { onRequest } from "firebase-functions/v2/https";
import {
  buildSlackPayload, deduplicationKey, eventPrice, isSupportedEvent,
  isValidAuthorization, RevenueCatWebhookPayload,
} from "./revenuecat.js";

initializeApp();
const db = getFirestore();
const slackWebhookUrl = defineSecret("SLACK_WEBHOOK_URL");
const revenueCatWebhookSecret = defineSecret("REVENUECAT_WEBHOOK_SECRET");

export const revenueCatWebhook = onRequest(
  {
    region: "asia-northeast1", secrets: [slackWebhookUrl, revenueCatWebhookSecret],
    timeoutSeconds: 30, memory: "256MiB", invoker: "public",
  },
  async (request, response) => {
    if (request.method !== "POST") {
      response.set("Allow", "POST").status(405).send("Method Not Allowed");
      return;
    }
    if (!isValidAuthorization(request.get("authorization"), revenueCatWebhookSecret.value())) {
      logger.warn("Rejected RevenueCat webhook with invalid authorization");
      response.status(401).send("Unauthorized");
      return;
    }

    const payload = request.body as RevenueCatWebhookPayload | undefined;
    if (!payload?.event || typeof payload.event.type !== "string") {
      response.status(400).send("Invalid payload");
      return;
    }
    if (!isSupportedEvent(payload.event.type)) {
      logger.info("Ignoring unsupported RevenueCat event", { event: payload.event.type });
      response.status(200).send("Ignored");
      return;
    }
    const event = { ...payload.event, type: payload.event.type };
    if (typeof event.id !== "string" || event.id.length === 0) {
      response.status(400).send("Event ID is required");
      return;
    }

    const eventRef = db.collection("revenuecat_webhook_events").doc(deduplicationKey(event.id));
    const isDuplicate = await db.runTransaction(async (transaction) => {
      const existing = await transaction.get(eventRef);
      if (existing.exists) return true;
      transaction.create(eventRef, {
        eventId: event.id, eventType: event.type, status: "processing",
        receivedAt: FieldValue.serverTimestamp(),
      });
      return false;
    });
    if (isDuplicate) {
      logger.info("Skipping duplicate RevenueCat event", { eventId: event.id, event: event.type });
      response.status(200).send("Duplicate ignored");
      return;
    }

    const price = eventPrice(event);
    logger.info("Sending RevenueCat event to Slack", {
      event: event.type, product: event.product_id ?? null,
      user: event.app_user_id ?? null, price: price ?? null,
    });

    try {
      const slackResponse = await fetch(slackWebhookUrl.value(), {
        method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify(buildSlackPayload(event)), signal: AbortSignal.timeout(10_000),
      });
      if (!slackResponse.ok) {
        const responseText = await slackResponse.text();
        throw new Error(`Slack returned ${slackResponse.status}: ${responseText.slice(0, 200)}`);
      }
      await eventRef.update({ status: "delivered", deliveredAt: FieldValue.serverTimestamp() });
      logger.info("RevenueCat event sent to Slack", { eventId: event.id, event: event.type });
      response.status(200).send("OK");
    } catch (error) {
      // Permit RevenueCat's retry to attempt delivery again after a transient Slack failure.
      await eventRef.delete().catch((deleteError: unknown) =>
        logger.error("Failed to release RevenueCat event reservation", deleteError));
      logger.error("Failed to send RevenueCat event to Slack", error);
      response.status(502).send("Slack notification failed");
    }
  },
);
