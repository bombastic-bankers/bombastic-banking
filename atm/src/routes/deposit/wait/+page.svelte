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

<div class="mb-6 flex h-20 w-28 items-center justify-center">
	<span class="text-5xl">💵</span>
</div>

<h2 class="mb-2 text-3xl font-semibold text-white">Insert Your Cash</h2>

<p class="mb-3 text-lg text-gray-300">Please deposit your money</p>

<p class="text-sm text-gray-400">Deposit the money whenever you are ready</p>
