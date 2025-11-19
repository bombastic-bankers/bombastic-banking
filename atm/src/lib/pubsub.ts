import jwt from 'jsonwebtoken';
import Pusher from 'pusher-js';
import {
	PUBLIC_PUSHER_APP_KEY,
	PUBLIC_PUSHER_CLUSTER,
	PUBLIC_ATM_TOKEN // This will never leave the ATM hardware
} from '$env/static/public';

let pusherClient: Pusher | null = null;
let pusherChannel: ReturnType<Pusher['subscribe']> | null = null;
const atmId = (jwt.decode(PUBLIC_ATM_TOKEN) as jwt.JwtPayload).sub!;
console.log(`atmId=${atmId}`);

export function initChannel(): ReturnType<Pusher['subscribe']> {
	if (!pusherClient) {
		pusherClient = new Pusher(PUBLIC_PUSHER_APP_KEY, {
			cluster: PUBLIC_PUSHER_CLUSTER,
			channelAuthorization: {
				headers: { 'X-ATM-Key': PUBLIC_ATM_TOKEN },
				endpoint: '/pusher/auth',
				transport: 'ajax'
			}
		});
	}

	if (!pusherChannel) {
		pusherChannel = pusherClient.subscribe(`private-atm-${atmId}`);
	}

	return pusherChannel;
}
