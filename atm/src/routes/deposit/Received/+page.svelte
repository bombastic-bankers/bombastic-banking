<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	const amount = +page.url.searchParams.get('amount')!;
</script>

<div
	class="w-full h-full rounded-2xl p-10 shadow-xl text-center flex flex-col items-center justify-center"
>

	<h1 class="text-3xl font-extrabold text-gray-900 mb-2">
		Received {amount}
	</h1>

	<p class="text-gray-800 text-lg mb-10">
		Please collect your receipt.<br />
		Is there anything else you would like to do?
	</p>

	<!-- Button Row -->
	<div class="flex gap-8">
		<button
			on:click={() => goto('/deposit')}
			class="w-56 h-20 rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937]
				text-white text-md font-medium shadow-lg hover:brightness-110 transition
				flex items-center justify-center px-4 text-center"
		>
			Another Deposit<br />transaction
		</button>

		<button
			class="w-56 h-20 rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937]
				text-white text-md font-medium shadow-lg hover:brightness-110 transition
				flex items-center justify-center px-4 text-center"
		>
			Other Services
		</button>

		<button
			on:click={() => goto('/')}
			class="w-56 h-20 rounded-xl bg-linear-to-b from-[#4b5563] to-[#1f2937]
				text-white text-md font-medium shadow-lg hover:brightness-110 transition
				flex items-center justify-center px-4 text-center"
		>
			End Transaction
		</button>
	</div>
</div>

