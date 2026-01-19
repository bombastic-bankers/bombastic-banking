<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';

	const amount = +page.url.searchParams.get('amount')!;
</script>

<svelte:window
	ondepositconfirm={() => goto(`/deposit/received?amount=${amount}`)}
	ondepositcancel={() => goto('/deposit')}
/>

<div class="flex h-full w-full items-center justify-center rounded-xl bg-[#e5e7eb]">
	<p class="text-center text-2xl font-semibold text-gray-800">
		Please refer to your phone to confirm the deposit
	</p>
</div>
