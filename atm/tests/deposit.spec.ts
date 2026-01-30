import { test, expect } from '@playwright/test';
import { setupSSEMock } from './helpers/sse';
import { hydrationComplete } from './helpers/hydration';

test.describe('Deposit Flow', () => {
	test('should handle deposit-start event', async ({ page }) => {
		const { receiveEvent } = await setupSSEMock(page);
		await page.goto('/');
		await hydrationComplete(page);

		await receiveEvent('deposit-start');

		await expect(page).toHaveURL('/deposit');
		await expect(page.getByText(/Please place your cash in the deposit slot/i)).toBeVisible();
	});

	test('should handle deposit-count event', async ({ page }) => {
		const { receiveEvent } = await setupSSEMock(page);
		await page.goto('/deposit');
		await hydrationComplete(page);

		await page.locator('input[type="number"]').fill('150');
		await receiveEvent('deposit-count');

		await expect(page.getByText(/Please wait while your cash is being counted/i)).toBeVisible();
		await expect(page).toHaveURL('/deposit/review?amount=150', { timeout: 5000 });
	});

	test('should handle deposit-confirm event', async ({ page }) => {
		const { receiveEvent } = await setupSSEMock(page);
		await page.goto('/deposit/review?amount=150');
		await hydrationComplete(page);

		await receiveEvent('deposit-confirm');

		await expect(page).toHaveURL('/deposit/received?amount=150');
		await expect(page.getByText(/Received 150/i)).toBeVisible();
		await expect(page).toHaveURL('/', { timeout: 12000 });
	});

	test('should handle deposit-cancel event', async ({ page }) => {
		const { receiveEvent } = await setupSSEMock(page);
		await page.goto('/deposit/review?amount=150');
		await hydrationComplete(page);

		await receiveEvent('deposit-cancel');

		await expect(page).toHaveURL('/deposit');
	});

	test('should complete full deposit flow', async ({ page }) => {
		const { receiveEvent } = await setupSSEMock(page);
		await page.goto('/');
		await hydrationComplete(page);

		await receiveEvent('deposit-start');
		await expect(page).toHaveURL('/deposit');
		await expect(page.getByText(/Please place your cash in the deposit slot/i)).toBeVisible();

		await page.locator('input[type="number"]').fill('250');

		await receiveEvent('deposit-count');
		await expect(page.getByText(/Please wait while your cash is being counted/i)).toBeVisible();
		await expect(page).toHaveURL('/deposit/review?amount=250', { timeout: 5000 });

		await receiveEvent('deposit-confirm');
		await expect(page).toHaveURL('/deposit/received?amount=250');
		await expect(page.getByText(/Received 250/i)).toBeVisible();
		await expect(page).toHaveURL('/', { timeout: 12000 });
	});

	test('should handle deposit cancellation flow', async ({ page }) => {
		const { receiveEvent } = await setupSSEMock(page);
		await page.goto('/');
		await hydrationComplete(page);

		await receiveEvent('deposit-start');
		await expect(page).toHaveURL('/deposit');

		await page.locator('input[type="number"]').fill('100');

		await receiveEvent('deposit-count');
		await expect(page).toHaveURL('/deposit/review?amount=100', { timeout: 5000 });

		await receiveEvent('deposit-cancel');
		await expect(page).toHaveURL('/deposit');
		await expect(page.getByText(/Please place your cash in the deposit slot/i)).toBeVisible();
	});

	test('should handle exit event during deposit', async ({ page }) => {
		const { receiveEvent } = await setupSSEMock(page);
		await page.goto('/');
		await hydrationComplete(page);

		await receiveEvent('deposit-start');
		await expect(page).toHaveURL('/deposit');
		await expect(page.getByText(/Please place your cash in the deposit slot/i)).toBeVisible();

		await page.locator('input[type="number"]').fill('250');

		await receiveEvent('deposit-count');
		await expect(page.getByText(/Please wait while your cash is being counted/i)).toBeVisible();
		await expect(page).toHaveURL('/deposit/review?amount=250', { timeout: 5000 });

		await receiveEvent('deposit-confirm');
		await expect(page).toHaveURL('/deposit/received?amount=250');
		await expect(page.getByText(/Received 250/i)).toBeVisible();

		await receiveEvent('exit');
		await expect(page).toHaveURL('/', { timeout: 1000 });
	});
});

