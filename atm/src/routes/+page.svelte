<script lang="ts">
	import { goto } from '$app/navigation';
	import { getSSEContext } from '$lib/context';

	const addSSEListener = getSSEContext();
	$effect(() =>
		addSSEListener('withdraw', (event) => {
			const { amount } = JSON.parse(event.data);
			goto(`/withdraw?amount=${amount}`);
		})
	);
	$effect(() =>
		addSSEListener('initiate-deposit', () => {
			goto('/deposit/wait');
		})
	);
	$effect(() =>
		addSSEListener('indicate-touchless', () => {
			goto('/deposit/wait');
		})
	);
</script>

<h2 class="mb-2 text-3xl font-semibold text-white">Welcome</h2>
<p class="mb-10 text-lg text-gray-400">Tap phone or insert card</p>
