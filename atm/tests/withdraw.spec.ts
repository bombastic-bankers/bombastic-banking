import { test, expect } from '@playwright/test';
import { setupSSEMock } from './helpers/sse-mock';

test.describe('Withdrawal Flow', () => {
	test('should handle withdraw event and complete withdrawal', async ({ page }) => {
		const { sendEvent } = await setupSSEMock(page);

		await page.goto('/');

		// Send withdraw event from mobile app
		await sendEvent('withdraw', { amount: 100 });

		// Verify navigation to withdraw page with correct amount
		await expect(page).toHaveURL('/withdraw?amount=100');

		// Verify "in progress" message is displayed
		await expect(page.getByText(/Withdrawing.*100.*in progress/i)).toBeVisible();

		// Wait for withdrawal simulation (3s) and verify completion
		await expect(page.getByText(/Withdraw Completed/i)).toBeVisible({ timeout: 5000 });

		// Verify auto-redirect to home after 10s
		await expect(page).toHaveURL('/', { timeout: 12000 });
	});

	test('should handle different withdrawal amounts', async ({ page }) => {
		const { sendEvent } = await setupSSEMock(page);

		await page.goto('/');

		// Test with amount 50
		await sendEvent('withdraw', { amount: 50 });
		await expect(page).toHaveURL('/withdraw?amount=50');
		await expect(page.getByText(/Withdrawing.*50.*in progress/i)).toBeVisible();
		
		// Wait for completion
		await expect(page.getByText(/Withdraw Completed/i)).toBeVisible({ timeout: 5000 });

		// Navigate back to home and wait for hydration
		await page.goto('/');
		await page.locator('body[data-mounted="true"]').waitFor({ timeout: 10000 });

		// Test with amount 200
		await sendEvent('withdraw', { amount: 200 });
		await expect(page).toHaveURL('/withdraw?amount=200');
		await expect(page.getByText(/Withdrawing.*200.*in progress/i)).toBeVisible();
		
		// Wait for completion
		await expect(page.getByText(/Withdraw Completed/i)).toBeVisible({ timeout: 5000 });
	});
});

