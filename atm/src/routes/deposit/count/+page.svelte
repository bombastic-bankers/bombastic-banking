<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { sendEvent } from '$lib/realtime.remote';
	import { deposit } from '$lib/simulate';
	import { onMount } from 'svelte';

	let depositCountingPromise = deposit();

	onMount(async () => {
		await depositCountingPromise;
		const amount = +page.url.searchParams.get('amount')!;
		await sendEvent({
			name: 'deposit-collected',
		});
		setTimeout(() => {
			goto('/deposit/Received?amount=' + amount);
		}, 10_000);
	});
</script>
<div class="w-full h-full bg-linear-to-b from-[#273245] to-[#1d2735] 
            rounded-2xl shadow-xl border border-[#394354] 
            flex flex-col items-center justify-center p-6">

		<p class="text-2xl font-bold text-white text-center">
				Please wait while we count your cash
		</p>
</div>


