import Ably from "ably";
import env from "../env.js";
import lazy from "../lazy.js";

const realtime = lazy(() => new Ably.Realtime({ key: env.ABLY_API_KEY }));

function atmChannelName(atmId: number) {
  return `atm:${atmId}`;
}

/** Publish an event to an ATM's pub/sub channel. */
export async function sendToATM(atmId: number, event: string, data?: any) {
  const ably = new Ably.Rest(env.ABLY_API_KEY);
  await ably.channels.get(atmChannelName(atmId)).publish(event, data);
}

/** Block until an event is received from an ATM's pub/sub channel, resolving with the event data. */
export async function waitForATM<T = any>(atmId: number, event: string): Promise<T> {
  const ably = new Ably.Realtime(env.ABLY_API_KEY);
  return new Promise<T>(async (resolve, _) => {
    await ably.channels.get(atmChannelName(atmId)).subscribe(event, (message) => {
      resolve(message.data);
      ably.close();
    });
  });
}

/**
 * Publish email verification success event to user's channel.
 */
export async function notifyEmailVerified(userId: number): Promise<void> {
  const channel = realtime.channels.get(`user:${userId}:email-verification`);
  await channel.publish("verified", { verified: true });
}

/**
 * Wait for email verification event on user's channel.
 * Returns a promise that resolves when verification occurs or rejects on timeout.
 */
export function waitForEmailVerification(userId: number, timeoutMs: number = 5 * 60 * 1000): Promise<void> {
  return new Promise((resolve, reject) => {
    const channel = realtime.channels.get(`user:${userId}:email-verification`);
    const timeout = setTimeout(() => {
      channel.unsubscribe("verified", listener);
      channel.detach();
      reject(new Error("Verification timeout"));
    }, timeoutMs);

    const listener = () => {
      clearTimeout(timeout);
      channel.unsubscribe("verified", listener);
      channel.detach();
      resolve();
    };

    channel.subscribe("verified", listener);
  });
}
