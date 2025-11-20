<script>
	import { goto } from '$app/navigation';
	import { sendEvent } from '$lib/realtime.remote';
	import { onMount } from 'svelte';
	export let next = '../withdraw-completion/deposit';
	export let delay = 3000;

	onMount(() => {
		setTimeout(() => {
			sendEvent({ name: 'deposit-collected', data: { amount: 100 } });
			goto(next);
		}, delay);
	});
</script>

<div class="mt-12 flex flex-col items-center">
	<div
		class="mb-6 h-14 w-14 animate-spin rounded-full border-4 border-green-500 border-t-transparent"
	></div>

	<h2 class="mb-2 text-2xl font-semibold text-white">Depositing in Process...</h2>

	<p class="mb-6 text-sm text-gray-400">Please wait</p>

	<div class="flex gap-2">
		<div class="h-3 w-3 animate-bounce rounded-full bg-green-500"></div>
		<div class="h-3 w-3 animate-bounce rounded-full bg-green-500 delay-150"></div>
		<div class="h-3 w-3 animate-bounce rounded-full bg-green-500 delay-300"></div>
	</div>
</div>
