/**
 * Simulate a physical (hardware) withdrawal, returning a
 * `Promise` that resolves when the withdrawal is complete.
 */
export async function withdraw(): Promise<void> {
	await new Promise((resolve) => {
		setTimeout(resolve, 3000);
	});
}

/**
 * Simulate physical (hardware) deposit counting, returning
 * a `Promise` that resolves when the counting is complete.
 */
export async function deposit(): Promise<void> {
	await new Promise((resolve) => {
		setTimeout(resolve, 3000);
	});
}
