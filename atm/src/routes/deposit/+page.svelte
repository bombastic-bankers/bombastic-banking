<script lang="ts">
    import { goto } from '$app/navigation';
    import { getSSEContext } from '$lib/context';

	// TODO: Simulated ATM UI to select this
	const simulatedDepositAmount = 50;
	const addSSEListener = getSSEContext();
	$effect(() =>
		addSSEListener('confirm-deposit', () => {
			goto('/deposit/count?amount=' + simulatedDepositAmount);
		})
	);
</script>

<!-- MAIN DEPOSIT SLOT SCREEN -->
<div class="w-full h-full bg-linear-to-b from-[#273245] to-[#1d2735] 
            rounded-2xl shadow-xl border border-[#394354] 
            flex flex-col items-center justify-center p-6">

    <div class="flex flex-col items-center justify-center">

		 <!-- Deposit Slot -->
		<div class="relative flex items-center justify-center">

			<!-- Outer silver frame -->
			<div class="w-48 h-16 bg-gray-300 rounded-xl shadow-inner flex items-center justify-center">

				<!-- Inner dark slot -->
				<div class="w-[85%] h-[55%] bg-[#1f2937] rounded-md flex items-center justify-between px-3">
					<!-- left dash -->
					<div class="w-6 h-0.5 bg-white"></div>
					<!-- right dash -->
					<div class="w-6 h-0.5 bg-white"></div>
				</div>
			</div>

			<!-- Left arrow -->
			<div class="absolute -left-5 text-2xl text-white">&lt;</div>

			<!-- Right arrow -->
			<div class="absolute -right-5 text-2xl text-white">&gt;</div>
		</div>
		
        <p class="text-white text-lg font-semibold text-center mt-4">
            Please place your cash in the deposit slot
        </p>
    </div>

</div>
