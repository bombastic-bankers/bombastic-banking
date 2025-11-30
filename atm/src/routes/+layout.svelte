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


<!-- OUTER ATM BACKGROUND -->
<div class="relative flex min-h-screen justify-center bg-black pt-10 pb-40">

    <!-- INNER SCREEN / WHITE BOX -->
    <div class="w-[90%] max-w-[900px] h-screen bg-[#e5e7eb] rounded-2xl p-6 shadow-xl border border-gray-300">
        {@render children()}
    </div>

    <!-- BOTTOM VENTS (below the screen) -->
    <div class="absolute top-[calc(100vh+5rem)] w-[90%] max-w-[900px]
         bg-white rounded-xl shadow-md flex items-center justify-center
         gap-6 py-3 px-6">

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
