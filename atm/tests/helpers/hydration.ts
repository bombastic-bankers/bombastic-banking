import type { Page } from '@playwright/test';

/**
 * Waits for Svelte to complete hydration.
 */
export async function hydrationComplete(page: Page) {
	await page.locator('body[data-mounted="true"]').waitFor({ timeout: 5000 });
}
