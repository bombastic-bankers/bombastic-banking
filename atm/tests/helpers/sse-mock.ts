import type { Page } from '@playwright/test';

export interface SSEMockContext {
	page: Page;
	sendEvent: (type: string, data?: any) => Promise<void>;
}

/**
 * Sets up SSE mocking for the /commands endpoint.
 * Returns a page and a sendEvent function to simulate incoming Ably events.
 */
export async function setupSSEMock(page: Page): Promise<SSEMockContext> {
	let hydrationChecked = false;

	// Intercept the /commands SSE endpoint and prevent it from connecting
	await page.route('**/commands', async (route) => {
		// Return a hanging response to prevent actual SSE connection
		await route.fulfill({
			status: 200,
			headers: {
				'Content-Type': 'text/event-stream',
				'Cache-Control': 'no-cache',
				Connection: 'keep-alive'
			},
			body: ''
		});
	});

	const sendEvent = async (type: string, data?: any) => {
		// Wait for Svelte to fully hydrate on first event send
		if (!hydrationChecked) {
			await page.locator('body[data-mounted="true"]').waitFor({ timeout: 10000 });
			hydrationChecked = true;
		}

		// Directly dispatch the custom event on the window object
		// This simulates what the SSE handler does in +layout.svelte
		await page.evaluate(
			({ eventType, eventData }) => {
				// Remove dashes from event type (e.g., "deposit-start" becomes "depositstart")
				const normalizedType = eventType.replaceAll('-', '');
				window.dispatchEvent(new CustomEvent(normalizedType, { detail: eventData }));
			},
			{ eventType: type, eventData: data }
		);

		// Give the page time to process the event
		await page.waitForTimeout(100);
	};

	return { page, sendEvent };
}

