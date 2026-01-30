import { test, expect } from '@playwright/test';
import { setupSSEMock } from './helpers/sse';
import { hydrationComplete } from './helpers/hydration';

test.describe('Withdrawal Flow', () => {
	test('should handle withdraw event and complete withdrawal', async ({ page }) => {
		const { receiveEvent: sendEvent } = await setupSSEMock(page);
		await page.goto('/');
		await hydrationComplete(page);

		await sendEvent('withdraw', { amount: 100 });

		await expect(page).toHaveURL('/withdraw?amount=100');
		await expect(page.getByText(/Withdrawing.*100.*in progress/i)).toBeVisible();
		await expect(page.getByText(/Withdraw Completed/i)).toBeVisible({ timeout: 5000 });
		await expect(page).toHaveURL('/', { timeout: 12000 });
	});

	test('should handle exit event', async ({ page }) => {
		const { receiveEvent: sendEvent } = await setupSSEMock(page);
		await page.goto('/');
		await hydrationComplete(page);

		await sendEvent('withdraw', { amount: 100 });
		await expect(page).toHaveURL('/withdraw?amount=100');
		await expect(page.getByText(/Withdrawing.*100.*in progress/i)).toBeVisible();
		await expect(page.getByText(/Withdraw Completed/i)).toBeVisible({ timeout: 5000 });

		await sendEvent('exit');
		await expect(page).toHaveURL('/', { timeout: 1000 });
	});
});

