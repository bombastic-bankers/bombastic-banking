<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { sendEvent } from '$lib/realtime.remote';
	import { withdraw } from '$lib/simulate';
	import { onMount } from 'svelte';

	let amount = +(page.url.searchParams.get('amount') || 0);
	let withdrawPromise = withdraw();

	onMount(async () => {
		await withdrawPromise;
		setTimeout(() => goto('/'), 10_000);
		await sendEvent({ name: 'withdraw-ready' });
	});
</script>

{#await withdrawPromise}
	<div class="mt-12 flex flex-col items-center">
		<div
			class="mb-6 h-14 w-14 animate-spin rounded-full border-4 border-green-500 border-t-transparent"
		></div>

		<h2 class="mb-2 text-2xl font-semibold text-white">Withdrawing ${amount}...</h2>

		<p class="mb-6 text-sm text-gray-400">Please wait</p>

		<div class="flex gap-2">
			<div class="h-3 w-3 animate-bounce rounded-full bg-green-500"></div>
			<div class="h-3 w-3 animate-bounce rounded-full bg-green-500 delay-150"></div>
			<div class="h-3 w-3 animate-bounce rounded-full bg-green-500 delay-300"></div>
		</div>
	</div>
{:then}
	<div class="mb-6 flex h-20 w-28 items-center justify-center">
		<span class="text-5xl">💵</span>
	</div>

	<h2 class="mb-2 text-3xl font-semibold text-white">Cash Ready!</h2>

	<p class="mb-3 text-lg text-gray-300">Please take your cash</p>

	<p class="mb-8 text-lg text-green-400">
		Amount: ${amount}
	</p>

	<p class="text-sm text-gray-400">Take out the cash whenever you are ready</p>
{/await}
