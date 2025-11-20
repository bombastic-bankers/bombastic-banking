import type { RequestHandler } from './$types';
import { channel, realtime } from '$lib/server/ably.js';

export const GET: RequestHandler = async ({ request }) => {
	console.log(`sse endpoint hit`);

	// Create a ReadableStream for SSE
	const stream = new ReadableStream({
		async start(controller) {
			// const encoder = new TextEncoder();

			await channel.subscribe((message) => {
				console.log(`message received: ${message.name!}`);
				controller.enqueue(
					`data: ${JSON.stringify({ name: message.name, data: message.data })}\n\n`
				);
				console.log(`message forwarded to sse: ${message.name!}`);
			});

			// Cleanup when client disconnects
			request.signal.addEventListener('abort', () => {
				realtime.close();
				// controller.close();
			});
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
