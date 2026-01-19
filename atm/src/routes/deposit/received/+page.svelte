<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/state';

	const amount = +page.url.searchParams.get('amount')!;

	onMount(async () => {
		setTimeout(() => goto('/'), 10_000);
	});
</script>

<div
	class="flex h-full w-full flex-col items-center justify-center rounded-2xl p-10 text-center shadow-xl"
>
	<h1 class="mb-2 text-3xl font-extrabold text-gray-900">
		Received {amount}
	</h1>

	<p class="mb-10 text-lg text-gray-800">
		Please collect your receipt.<br />
		Is there anything else you would like to do?
	</p>

	<!-- Button Row -->
	<div class="flex gap-8">
		<button
			on:click={() => goto('/deposit')}
			class="text-md flex h-20 w-56 items-center justify-center
				rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937] px-4 text-center
				font-medium text-white shadow-lg transition hover:brightness-110"
		>
			Another Deposit<br />transaction
		</button>

		<button
			class="text-md flex h-20 w-56 items-center justify-center
				rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937] px-4 text-center
				font-medium text-white shadow-lg transition hover:brightness-110"
		>
			Other Services
		</button>

		<button
			on:click={() => goto('/')}
			class="text-md flex h-20 w-56 items-center justify-center
				rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937] px-4 text-center
				font-medium text-white shadow-lg transition hover:brightness-110"
		>
			End Transaction
		</button>
	</div>
</div>
