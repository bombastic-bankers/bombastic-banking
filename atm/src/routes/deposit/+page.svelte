<script lang="ts">
	import { goto } from '$app/navigation';

	// TODO: Simulated ATM UI to select this
	const simulatedDepositAmount = 50;
</script>

<svelte:window ondepositconfirm={() => goto('/deposit/count?amount=' + simulatedDepositAmount)} />

<!-- MAIN DEPOSIT SLOT SCREEN -->
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
				<div class="flex h-[55%] w-[85%] items-center justify-between rounded-md bg-[#1f2937] px-3">
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
			<br />
			and refer to your phone for instructions
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

		<button
			onclick={() => submitAmount()}
			class="mt-4 w-full rounded-xl bg-blue-600 py-3 font-semibold text-white transition hover:bg-blue-700"
		>
			Confirm
		</button>
	</div>
</div>
