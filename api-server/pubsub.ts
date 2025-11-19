import PusherServer from "pusher";
import PusherClient from "pusher-js";
import {
  PUSHER_APP_ID,
  PUSHER_KEY,
  PUSHER_SECRET,
  PUSHER_CLUSTER,
  SERVER_SELF_AUTH_KEY,
} from "./env.js";

// The API server needs both the Pusher server and client libraries because
// the Pusher server library doesn't allow listening to client-sent events,
// which the API server needs to handle ATM status updates.
//
// Pusher's recommendation is to use their webhooks to receive client-sent
// events, but that doesn't allow us to listen to those client-sent events
// directly from the controllers (e.g. /touchless/:atmId/withdraw) that send
// the ATM commands, which is necessary because most of those controllers
// only return when the ATM has processed the command and sent a status update.
//
// So instead, we use the Pusher client library on this API server to listen
// to client-sent events directly from those controllers.

export const pusherServer = new PusherServer({
  appId: PUSHER_APP_ID,
  key: PUSHER_KEY,
  secret: PUSHER_SECRET,
  cluster: PUSHER_CLUSTER,
  useTLS: true,
});

const pusherClient = new PusherClient(PUSHER_KEY, {
  cluster: PUSHER_CLUSTER,
  channelAuthorization: {
    endpoint: "/pusher/auth",
    headers: { "X-Server-Key": SERVER_SELF_AUTH_KEY },
    transport: "ajax",
  },
});

function atmChannelName(atmId: number) {
  return `private-atm-${atmId}`;
}

export async function sendToATM(atmId: number, event: string, data?: any) {
  const channelName = atmChannelName(atmId);
  await pusherServer.trigger(channelName, event, data);
}

export async function waitForATM(atmId: number, event: string): Promise<any> {
  const channelName = atmChannelName(atmId);

  return new Promise<any>((resolve, reject) => {
    pusherClient.subscribe(channelName).bind(event, async (data: any) => {
      pusherClient.unsubscribe(channelName);
      resolve(data);
    });
  });
}
