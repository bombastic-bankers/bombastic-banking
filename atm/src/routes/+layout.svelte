<script lang="ts">
	import '../app.css';
	import favicon from '$lib/assets/favicon.svg';
	import { onMount } from 'svelte';
	import { initChannel } from '$lib/pubsub';
	import { goto } from '$app/navigation';

	let { children } = $props();

	onMount(() => {
		const channel = initChannel();
		console.log('Channel created');
		channel.bind('withdraw', () => {
			console.log('Redirecting to withdraw amt page');
			goto('/amount/withdraw');
		});
	});
</script>

<svelte:head>
	<title>ATM Dashboard</title>
	<link rel="icon" href={favicon} />
</svelte:head>

<!-- Fullscreen Machine Background -->
<div class="flex h-screen w-screen items-center justify-center bg-[#111a27]">
	<!-- ATM Frame -->
	<div
		class="relative flex h-[80%] w-[90%] max-w-[900px]
           flex-col items-center rounded-3xl
           border border-gray-700 bg-[#0c1525] shadow-xl"
	>
		<!-- OCBC Top Bar -->
		<div
			class="flex h-20 w-full items-center justify-center rounded-t-3xl bg-red-600
                text-3xl font-semibold tracking-wide text-white"
		>
			OCBC
		</div>

		<!-- Main Screen Area -->
		<div class="relative flex w-full flex-1 flex-col items-center px-8 pt-2 pb-10 text-center">
			<!-- <div class="flex-1 w-full flex flex-col items-center text-center px-8 pt-4 pb-10 relative"> -->

			<!-- User Icon -->
			<div class="absolute top-6 right-6 flex items-center gap-3">
				<div
					class="flex h-12 w-12 items-center justify-center rounded-full bg-blue-500 text-2xl text-white"
				>
					👤
				</div>
				<p class="text-sm text-white/80">Welcome, Mike</p>
			</div>

			<!-- Page-Specific Content -->
			<div class="flex h-full w-full flex-col items-center pt-20">
				{@render children()}
			</div>
		</div>

		<!-- Bottom Vents + Card Slot -->
		<div class="absolute bottom-6 flex w-full flex-col items-center">
			<!-- Vents -->
			<div class="mb-3 flex w-[60%] justify-between text-gray-600">
				<div class="space-y-1">
					<div class="h-1 w-8 rounded bg-gray-700"></div>
					<div class="h-1 w-8 rounded bg-gray-700"></div>
					<div class="h-1 w-8 rounded bg-gray-700"></div>
				</div>
				<div class="space-y-1">
					<div class="h-1 w-8 rounded bg-gray-700"></div>
					<div class="h-1 w-8 rounded bg-gray-700"></div>
					<div class="h-1 w-8 rounded bg-gray-700"></div>
				</div>
			</div>

			<!-- Card Slot -->
			<div class="h-5 w-64 rounded-lg bg-black shadow-inner"></div>
		</div>
	</div>
</div>
