<script lang="ts">
	import { goto } from '$app/navigation';
	import { sendEvent } from '$lib/realtime.remote';
	import { deposit } from '$lib/simulate';

	let simulatedDepositAmount = $state(0);
	let countingDeposit = $state(false);
</script>

<svelte:window
	ondepositcount={async () => {
		countingDeposit = true;
		await deposit();
		await sendEvent({ name: 'deposit-review', data: { amount: simulatedDepositAmount } });
		goto(`/deposit/review?amount=${simulatedDepositAmount}`);
	}}
/>

{#if !countingDeposit}
	<div
		class="flex h-full w-full flex-col items-center
            justify-center rounded-2xl border border-[#394354]
            bg-linear-to-b from-[#273245] to-[#1d2735] p-6 shadow-xl"
	>
		<div class="flex flex-col items-center justify-center">
			<!-- Deposit Slot -->
			<div class="relative flex items-center justify-center">
				<!-- Outer silver frame -->
				<div class="flex h-16 w-48 items-center justify-center rounded-xl bg-gray-300 shadow-inner">
					<!-- Inner dark slot -->
					<div
						class="flex h-[55%] w-[85%] items-center justify-between rounded-md bg-[#1f2937] px-3"
					>
						<!-- left dash -->
						<div class="h-0.5 w-6 bg-white"></div>
						<!-- right dash -->
						<div class="h-0.5 w-6 bg-white"></div>
					</div>
				</div>

				<!-- Left arrow -->
				<div class="absolute -left-5 text-2xl text-white">&lt;</div>

				<!-- Right arrow -->
				<div class="absolute -right-5 text-2xl text-white">&gt;</div>
			</div>

			<p class="mt-4 text-center text-lg font-semibold text-white">
				Please place your cash in the deposit slot
			</p>
		</div>

		<!-- Floating Deposit Amount Panel -->
		<div
			class="fixed right-6 bottom-6 z-50 w-[200px] rounded-2xl border border-gray-300 bg-white p-5 shadow-2xl"
		>
			<h3 class="mb-2 text-xl font-bold text-gray-900">Enter Amount</h3>

			<input
				type="number"
				bind:value={simulatedDepositAmount}
				placeholder="e.g. 100"
				class="w-full rounded-xl border border-gray-300 p-3 text-gray-800 focus:ring-2 focus:ring-blue-500 focus:outline-none"
			/>
		</div>
	</div>
{:else}
	<div
		class="flex h-full w-full flex-col items-center
            justify-center rounded-2xl border border-[#394354]
            bg-linear-to-b from-[#273245] to-[#1d2735] p-6 shadow-xl"
	>
		<p class="text-center text-2xl font-bold text-white">
			Please wait while your cash is being counted
		</p>
	</div>
{/if}
