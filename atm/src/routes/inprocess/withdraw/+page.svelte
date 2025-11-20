<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { sendEvent } from '$lib/realtime.remote';
	import { onMount } from 'svelte';

	let amount = +(page.url.searchParams.get('amount') || 0);
	const simulatedWithdrawalDelay = 3000;

	onMount(() => {
		setTimeout(async () => {
			await sendEvent({ name: 'withdraw-ready' });
			goto(`/ready/withdraw?amount=${amount}`);
		}, simulatedWithdrawalDelay);
	});
</script>

<div class="mt-12 flex flex-col items-center">
	<div
		class="mb-6 h-14 w-14 animate-spin rounded-full border-4 border-green-500 border-t-transparent"
	></div>

	<h2 class="mb-2 text-2xl font-semibold text-white">Withdrawing in Process...</h2>

	<p class="mb-6 text-sm text-gray-400">Please wait</p>

	<div class="flex gap-2">
		<div class="h-3 w-3 animate-bounce rounded-full bg-green-500"></div>
		<div class="h-3 w-3 animate-bounce rounded-full bg-green-500 delay-150"></div>
		<div class="h-3 w-3 animate-bounce rounded-full bg-green-500 delay-300"></div>
	</div>
</div>
