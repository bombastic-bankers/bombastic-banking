<script>
	import { page } from '$app/stores';
	$: amount = $page.url.searchParams.get('amount') || 0;

	import { goto } from '$app/navigation';
	export let next = '../inprocess/deposit';
	export let delay = 3000;

	setTimeout(() => goto(next), delay);
</script>

<div class="mb-6 flex h-20 w-28 items-center justify-center">
	<span class="text-5xl">💵</span>
</div>

<h2 class="mb-2 text-3xl font-semibold text-white">Insert Your Cash</h2>

<p class="mb-3 text-lg text-gray-300">Please deposit your money</p>

<p class="mb-8 text-lg text-green-400">
	Amount: ${amount}
</p>

<p class="text-sm text-gray-400">Deposit the money whenever you are ready</p>
