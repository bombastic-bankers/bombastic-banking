import { command } from '$app/server';
import { channel } from '$lib/server/ably';
import z from 'zod';

/** Send a realtime event to the API server. */
export const sendEvent = command(
	z.object({ name: z.string(), data: z.any().optional() }),
	async (event) => {
		channel.publish(event.name, event.data);
	}
);
