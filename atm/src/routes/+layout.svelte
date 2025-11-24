<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';
	import { setSSEContext } from '$lib/context';

	let { children } = $props();

	let eventSource: EventSource | undefined = $state(undefined);
	setSSEContext((event, listener) => {
		if (!eventSource) return () => {};
		eventSource.addEventListener(event, listener);
		return () => eventSource?.removeEventListener(event, listener);
	});
	onMount(() => {
		eventSource = new EventSource('/commands');
	});
</script>

<svelte:head>
	<title>ATM Dashboard</title>
</svelte:head>

<!-- Fullscreen machine background -->
<div class="flex h-screen w-screen items-start justify-center bg-[#0f1a27] pt-10">


	<!-- ATM outer frame -->
	<div
		class="relative flex h-[80%] w-[88%] max-w-[1100px]
		flex-col items-center rounded-[32px]
		border border-gray-700 bg-[#0c1525] shadow-2xl"
	>

		<!-- INNER SCREEN -->
		<div class="flex flex-col items-center w-full flex-1 px-12 py-10 text-center ">
			{@render children()}
		</div>

		<!-- Bottom vents -->
		<div class="absolute bottom-[-80px] w-[90%] max-w-[900px] bg-white rounded-xl shadow-md 
            flex items-center justify-center gap-6 py-3 px-6">

			<div class="flex items-center gap-2 font-semibold text-red-600">
				<div class="w-5 h-5 bg-red-600 rounded-full flex items-center justify-center text-white text-xs">O</div>
				OCBC
			</div>

			<div class="px-4 py-1 rounded-md border border-blue-600 text-blue-600 font-medium text-sm">
				VISA
			</div>

			<div class="px-4 py-1 rounded-md border border-blue-600 text-blue-600 font-medium text-sm">
				PLUS
			</div>

			<div class="flex items-center">
				<div class="w-5 h-5 rounded-full bg-[#eb001b]"></div>
				<div class="w-5 h-5 rounded-full bg-[#f79e1b] -ml-2"></div>
			</div>

			<div class="px-4 py-1 rounded-md border border-blue-600 text-blue-600 font-medium text-sm">
				Maestro
			</div>

			<span class="text-blue-600 font-medium">Cirrus</span>

			<span class="text-red-600 font-medium">UnionPay</span>

			<span class="text-blue-700 font-medium">UOB</span>
		</div>
	</div>
</div>
