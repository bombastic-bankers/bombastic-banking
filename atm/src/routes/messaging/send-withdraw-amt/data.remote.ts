import { query } from '$app/server';
import { channel } from '$lib/server/ably';

export const sendWithdrawReady = query(async () => {
	channel.publish('withdraw-ready', {});
});
