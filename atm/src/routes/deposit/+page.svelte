<script lang="ts">
    import { goto } from '$app/navigation';
    import { getSSEContext } from '$lib/context';

	let simulatedDepositAmount = $state("");
	const addSSEListener = getSSEContext();
	$effect(() =>
		addSSEListener('confirm-deposit', () => {
			goto('/deposit/count?amount=' + simulatedDepositAmount);
		})
	);

    function submitAmount() {
        if (!simulatedDepositAmount) {
            alert("Please enter an amount.");
            return;
        }
        console.log("Deposit:", simulatedDepositAmount);
        // you can replace this with your goto or API call
    }
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
			<br>
			and refer to your phone for instructions 
        </p>
    </div>

	<!-- Floating Deposit Amount Panel -->
	<div 
		class="fixed bottom-6 right-6 bg-white p-5 rounded-2xl shadow-2xl border border-gray-300 w-[200px] z-50"
	>
		<h3 class="text-xl font-bold mb-2 text-gray-900">Enter Amount</h3>

		<input 
			type="number"
			bind:value={simulatedDepositAmount}
			placeholder="e.g. 100"
			class="w-full p-3 border border-gray-300 rounded-xl text-gray-800 focus:outline-none focus:ring-2 focus:ring-blue-500"
		/>

		<button
			onclick={() => submitAmount()}
			class="mt-4 w-full py-3 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 transition"
		>
			Confirm
		</button>
	</div>
</div>
