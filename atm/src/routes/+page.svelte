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
			goto('/deposit');
		})
	);
	$effect(() =>
		addSSEListener('indicate-touchless', () => {
			goto('/deposit');
		})
	);
</script>


<!-- MAIN SCREEN CONTENT -->
<div
	class="w-full  max-w-[900px] mx-auto bg-[#e5e7eb] rounded-2xl p-1 shadow-xl text-left border border-gray-300"
>

	<div class="flex items-start gap-10 mb-1">
		<div class="text-5xl leading-none ml-10">⚠️</div>
		<div>
			<h1 class="text-3xl font-extrabold tracking-wide text-gray-900">
				STAY SAFE, BE VIGILANT ALWAYS.
			</h1>

			<p class="mt-3 text-gray-700 text-lg leading-relaxed">
				Before using this machine, if you suspect it has been tampered with or if
				there are suspicious individuals nearby, please choose another machine or
				return at another time.<br />
				For any security concerns, contact <span class="font-semibold">1800 363 3333</span>.
			</p>
			<br>

			<div class="mb-5">
				<h2 class="text-2xl font-bold text-gray-900">时刻保持警惕</h2>
				<p class="mt-3 text-gray-700 text-lg leading-relaxed">
					在使用提款机之前，如果发现提款机曾被人动过手脚或附近有任何可疑人物，
					请选择改用其他地点的提款机或改在其他时间前来使用。<br />
					若有任何保安方面的疑虑，请拨电
					<span class="font-semibold">1800 363 3333</span> 查询。
				</p>
			</div>
		</div>
	</div>

	<!-- Action Buttons -->
	<div class="flex justify-center gap-10">

		<button
			onclick={() => goto('/instructions?next=/withdraw')}
			class="w-50 h-20 rounded-2xl bg-gradient-to-b from-[#353b4b] to-[#1f2330]
			text-white text-lg font-medium shadow-lg hover:brightness-110 transition
			flex flex-col items-center justify-center"
		>
			Withdraw cash
			<span class="text-sm text-gray-300 mt-1">using OCBC app</span>
		</button>

		<button
			onclick={() => goto('/instructions?next=/deposit')}
			class="w-50 h-20 rounded-2xl bg-gradient-to-b from-[#353b4b] to-[#1f2330]
			text-white text-lg font-medium shadow-lg hover:brightness-110 transition
			flex flex-col items-center justify-center"
		>
			Non-Card / Business
			<span class="text-sm text-gray-300 mt-1">Deposit Services</span>
		</button>

		<button
			onclick={() => goto('/instructions?next=/payout')}
			class="w-50 h-20 rounded-2xl bg-gradient-to-b from-[#353b4b] to-[#1f2330]
			text-white text-lg font-medium shadow-lg hover:brightness-110 transition
			flex flex-col items-center justify-center"
		>
			Government Payout
		</button>
	</div>
</div>

