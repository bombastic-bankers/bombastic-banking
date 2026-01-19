import Ably from "ably";
import env from "./env.js";

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
