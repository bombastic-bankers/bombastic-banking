import type { Page } from '@playwright/test';

export interface EventTrackingContext {
	page: Page;
	waitForEvent: (name: string, timeout?: number) => Promise<{ name: string; data?: any }>;
	getEvents: () => Array<{ name: string; data?: any }>;
	clearEvents: () => void;
}

/**
 * Sets up event tracking for outgoing ATM events.
 * Intercepts sendEvent command calls and stores them for assertions.
 */
export async function setupEventTracking(page: Page): Promise<EventTrackingContext> {
	const events: Array<{ name: string; data?: any }> = [];

	// Intercept all POST requests
	await page.route('**/*', async (route) => {
		const request = route.request();
		
		// Check if this is a POST request (SvelteKit commands use POST)
		if (request.method() === 'POST') {
			const postData = request.postDataJSON();
			
			// Check if this looks like a sendEvent command
			if (postData && typeof postData === 'object' && 'name' in postData) {
				events.push({ name: postData.name, data: postData.data });
			}
			
			// Continue with the request
			await route.continue();
		} else {
			await route.continue();
		}
	});

	const waitForEvent = async (name: string, timeout = 5000): Promise<{ name: string; data?: any }> => {
		const startTime = Date.now();
		while (Date.now() - startTime < timeout) {
			const event = events.find((e) => e.name === name);
			if (event) {
				return event;
			}
			await page.waitForTimeout(100);
		}
		throw new Error(`Event "${name}" not received within ${timeout}ms`);
	};

	const getEvents = () => [...events];
	const clearEvents = () => {
		events.length = 0;
	};

	return { page, waitForEvent, getEvents, clearEvents };
}

