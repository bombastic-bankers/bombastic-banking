<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';

	let { children } = $props();

	// Dispatch events received from the ATM server on window
	onMount(() => {
		// Indicate that Svelte has finished hydration, for Playwright to wait on
		document.body.setAttribute('data-mounted', 'true');

		const eventSource = new EventSource('/commands');
		eventSource.addEventListener('message', (event) => {
			const msg: { type: string; data: any } = JSON.parse(event.data);
			// Remove dashes, so (e.g.) "deposit-start" becomes "depositstart",
			// to allow listeners to follow casing conventions (e.g. "ondepositstart")
			window.dispatchEvent(new CustomEvent(msg.type.replaceAll('-', ''), { detail: msg.data }));
		});
	});
</script>

<svelte:head>
	<title>ATM Dashboard</title>
</svelte:head>

<!-- OUTER ATM BACKGROUND -->
<div class="relative flex min-h-screen justify-center bg-black pt-10 pb-40">
	<!-- INNER SCREEN / WHITE BOX -->
	<div
		class="h-[650px] w-[90%] max-w-[900px] rounded-2xl border border-gray-300 bg-[#e5e7eb] p-6 shadow-xl"
	>
		{@render children()}
	</div>

	<!-- BOTTOM VENTS (below the screen) -->
	<div
		class="absolute top-[calc(100vh+5rem)] flex w-[90%]
         max-w-[900px] items-center justify-center gap-6 rounded-xl bg-white
         px-6 py-3 shadow-md"
	>
		<img src="/logos/ocbc.png" class="h-6 object-contain" alt="OCBC" />
		<img src="/logos/visa.png" class="h-6 object-contain" alt="Visa" />
		<img src="/logos/plus.png" class="h-6 object-contain" alt="Plus" />
		<img src="/logos/mastercard.png" class="h-6 object-contain" alt="Mastercard" />
		<img src="/logos/maestro.png" class="h-6 object-contain" alt="Maestro" />
		<img src="/logos/cirrus.png" class="h-6 object-contain" alt="Cirrus" />
		<img src="/logos/unionpay.png" class="h-6 object-contain" alt="UnionPay" />
		<img src="/logos/uob.png" class="h-6 object-contain" alt="UOB" />
	</div>
</div>
