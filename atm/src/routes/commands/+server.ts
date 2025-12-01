import type { RequestHandler } from './$types';
import { channel } from '$lib/server/ably.js';

/** SSE endpoint to relay ATM commands from Ably to the front-end. */
export const GET: RequestHandler = async () => {
	const stream = new ReadableStream({
		async start(controller) {
			await channel.subscribe((message) => {
				// For compatability with older API server version
				if (message.name === 'initiate-deposit') {
					message.name = 'deposit-start';
				} else if (message.name === 'indicate-touchless') {
					message.name = 'app-instruction';
				}

				controller.enqueue(`data: ${JSON.stringify({ type: message.name, data: message.data })}\n\n`);
			});
		},
		cancel() {
			channel.unsubscribe();
		}
	});

	return new Response(stream, {
		headers: {
			'Content-Type': 'text/event-stream',
			'Cache-Control': 'no-cache',
			Connection: 'keep-alive'
		}
	});
};
