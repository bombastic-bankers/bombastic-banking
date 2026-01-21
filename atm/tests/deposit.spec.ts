import { test, expect } from '@playwright/test';
import { setupSSEMock } from './helpers/sse-mock';

test.describe('Deposit Flow', () => {
	test('should handle deposit-start event', async ({ page }) => {
		const { sendEvent } = await setupSSEMock(page);

		await page.goto('/');

		// Send deposit-start event from mobile app
		await sendEvent('deposit-start');

		// Verify navigation to deposit page
		await expect(page).toHaveURL('/deposit');

		// Verify deposit slot UI is displayed
		await expect(page.getByText(/Please place your cash in the deposit slot/i)).toBeVisible();
	});

	test('should handle deposit-count event', async ({ page }) => {
		const { sendEvent } = await setupSSEMock(page);

		await page.goto('/deposit');

		// Set the simulated deposit amount via the input field
		await page.locator('input[type="number"]').fill('150');

		// Send deposit-count event
		await sendEvent('deposit-count');

		// Verify counting message is displayed
		await expect(page.getByText(/Please wait while your cash is being counted/i)).toBeVisible();

		// Wait for counting simulation (3s) and verify navigation to review
		await expect(page).toHaveURL('/deposit/review?amount=150', { timeout: 5000 });
	});

	test('should handle deposit-confirm event', async ({ page }) => {
		const { sendEvent } = await setupSSEMock(page);

		await page.goto('/deposit/review?amount=150');

		// Send deposit-confirm event from mobile app
		await sendEvent('deposit-confirm');

		// Verify navigation to received page
		await expect(page).toHaveURL('/deposit/received?amount=150');

		// Verify confirmation message
		await expect(page.getByText(/Received 150/i)).toBeVisible();

		// Verify auto-redirect to home after 10s
		await expect(page).toHaveURL('/', { timeout: 12000 });
	});

	test('should handle deposit-cancel event', async ({ page }) => {
		const { sendEvent } = await setupSSEMock(page);

		await page.goto('/deposit/review?amount=150');

		// Send deposit-cancel event from mobile app
		await sendEvent('deposit-cancel');

		// Verify navigation back to deposit page
		await expect(page).toHaveURL('/deposit');
	});

	test('should complete full deposit flow', async ({ page }) => {
		const { sendEvent } = await setupSSEMock(page);

		await page.goto('/');

		// Step 1: Start deposit
		await sendEvent('deposit-start');
		await expect(page).toHaveURL('/deposit');
		await expect(page.getByText(/Please place your cash in the deposit slot/i)).toBeVisible();

		// Set the simulated deposit amount
		const amountInput = page.locator('input[type="number"]');
		await amountInput.fill('250');

		// Step 2: Count deposit
		await sendEvent('deposit-count');
		await expect(page.getByText(/Please wait while your cash is being counted/i)).toBeVisible();

		// Wait for review page
		await expect(page).toHaveURL('/deposit/review?amount=250', { timeout: 5000 });

		// Step 3: Confirm deposit
		await sendEvent('deposit-confirm');
		await expect(page).toHaveURL('/deposit/received?amount=250');
		await expect(page.getByText(/Received 250/i)).toBeVisible();

		// Verify auto-redirect to home
		await expect(page).toHaveURL('/', { timeout: 12000 });
	});

	test('should handle deposit cancellation flow', async ({ page }) => {
		const { sendEvent } = await setupSSEMock(page);

		await page.goto('/');

		// Start and count deposit
		await sendEvent('deposit-start');
		await expect(page).toHaveURL('/deposit');

		// Set amount
		const amountInput = page.locator('input[type="number"]');
		await amountInput.fill('100');

		await sendEvent('deposit-count');
		await expect(page).toHaveURL('/deposit/review?amount=100', { timeout: 5000 });

		// Cancel instead of confirming
		await sendEvent('deposit-cancel');
		await expect(page).toHaveURL('/deposit');

		// Should be able to start a new deposit
		await expect(page.getByText(/Please place your cash in the deposit slot/i)).toBeVisible();
	});
});

