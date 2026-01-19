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
	<div class="w-full h-full bg-linear-to-b from-[#273245] to-[#1d2735] 
            rounded-2xl shadow-xl border border-[#394354] 
            flex flex-col items-center justify-center p-6">

		<p class="text-2xl font-bold text-white text-center">
				Withdrawing ${amount} in progress...
		</p>

	</div>
{:then}
	<div class="w-full h-full bg-[#e5e7eb] rounded-2xl p-10 shadow-xl text-center border border-gray-300 flex flex-col items-center justify-center"
>
		<h1 class="text-3xl font-extrabold text-gray-900 mb-2">
			Withdraw Completed
		</h1>

		<p class="text-gray-800 text-lg mb-10">
			Please collect your receipt.<br />
			Is there anything else you would like to do?
		</p>

		<div class="flex gap-8">

			<button
				onclick={() => goto('/withdraw')}
				class="w-56 h-20 rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937]
					text-white text-md font-medium shadow-lg hover:brightness-110 transition
					flex items-center justify-center px-4 text-center"
			>
				Another Withdraw
			</button>

			<button class="w-56 h-20 rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937]
				text-white text-md font-medium shadow-lg hover:brightness-110 transition
				flex items-center justify-center px-4 text-center">
				Other Services
			</button>

			<button
				onclick={() => goto('/')}
				class="w-56 h-20 rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937]
					text-white text-md font-medium shadow-lg hover:brightness-110 transition
					flex items-center justify-center px-4 text-center"
			>
				End Transaction
			</button>

		</div>
	</div>
{/await}
