import Ably from "ably";
import { ABLY_API_KEY } from "./env.js";

function atmChannelName(atmId: number) {
  return `atm:${atmId}`;
}

export async function sendToATM(atmId: number, event: string, data?: any) {
  const ably = new Ably.Rest(ABLY_API_KEY);
  await ably.channels.get(atmChannelName(atmId)).publish(event, data);
}

export async function waitForATM<T = any>(
  atmId: number,
  event: string,
): Promise<T> {
  const ably = new Ably.Realtime(ABLY_API_KEY);
  return new Promise<T>(async (resolve, reject) => {
    await ably.channels
      .get(atmChannelName(atmId))
      .subscribe(event, (message) => {
        resolve(message.data);
        ably.close();
      });
  });
}
