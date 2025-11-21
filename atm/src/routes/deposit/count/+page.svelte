<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { sendEvent } from '$lib/realtime.remote';
	import { deposit } from '$lib/simulate';
	import { onMount } from 'svelte';

	let depositCountingPromise = deposit();

	onMount(async () => {
		await depositCountingPromise;
		setTimeout(() => goto('/'), 10_000);
		await sendEvent({
			name: 'deposit-collected',
			// TODO: Better error handling
			data: { amount: +page.url.searchParams.get('amount')! }
		});
	});
</script>

{#await depositCountingPromise}
	<div class="mt-12 flex flex-col items-center">
		<div
			class="mb-6 h-14 w-14 animate-spin rounded-full border-4 border-green-500 border-t-transparent"
		></div>

		<h2 class="mb-2 text-2xl font-semibold text-white">Counting deposit...</h2>

		<p class="mb-6 text-sm text-gray-400">Please wait</p>

		<div class="flex gap-2">
			<div class="h-3 w-3 animate-bounce rounded-full bg-green-500"></div>
			<div class="h-3 w-3 animate-bounce rounded-full bg-green-500 delay-150"></div>
			<div class="h-3 w-3 animate-bounce rounded-full bg-green-500 delay-300"></div>
		</div>
	</div>
{:then _}
	<div class="flex h-18 w-18 items-center justify-center rounded-full border-4 border-green-500">
		<div class="h-12 w-6 rotate-45 border-r-4 border-b-4 border-green-500"></div>
	</div>
	<h2 class="mt-6 text-2xl font-semibold text-white">Deposit Complete!</h2>
	<p class="mt-1 text-gray-400">Thank you for using OCBC Bank ATM</p>
{/await}
