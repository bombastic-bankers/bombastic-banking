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

<svelte:window onexit={() => goto('/')} />

{#await withdrawPromise}
	<div
		class="flex h-full w-full flex-col items-center
            justify-center rounded-2xl border border-[#394354]
            bg-linear-to-b from-[#273245] to-[#1d2735] p-6 shadow-xl"
	>
		<p class="text-center text-2xl font-bold text-white">
			Withdrawing ${amount} in progress...
		</p>
	</div>
{:then}
	<div
		class="flex h-full w-full flex-col items-center justify-center rounded-2xl border border-gray-300 bg-[#e5e7eb] p-10 text-center shadow-xl"
	>
		<h1 class="mb-2 text-3xl font-extrabold text-gray-900">Withdraw Completed</h1>

		<p class="mb-10 text-lg text-gray-800">
			Please collect your receipt.<br />
			Is there anything else you would like to do?
		</p>

		<div class="flex gap-8">
			<button
				onclick={() => goto('/withdraw')}
				class="text-md flex h-20 w-56 items-center justify-center
					rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937] px-4 text-center
					font-medium text-white shadow-lg transition hover:brightness-110"
			>
				Another Withdraw
			</button>

			<button
				class="text-md flex h-20 w-56 items-center justify-center
				rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937] px-4 text-center
				font-medium text-white shadow-lg transition hover:brightness-110"
			>
				Other Services
			</button>

			<button
				onclick={() => goto('/')}
				class="text-md flex h-20 w-56 items-center justify-center
					rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937] px-4 text-center
					font-medium text-white shadow-lg transition hover:brightness-110"
			>
				End Transaction
			</button>
		</div>
	</div>
{/await}
