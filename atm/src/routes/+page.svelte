<script lang="ts">
	import { goto } from '$app/navigation';
</script>

<svelte:window
	onwithdraw={(event) => goto(`/withdraw?amount=${event.detail.amount}`)}
	ondepositstart={() => goto('/deposit')}
/>

<!-- MAIN SCREEN CONTENT -->
<!-- <div class="w-full min-h-screen bg-[#e5e7eb] rounded-2xl p-1 shadow-xl text-left border border-gray-300"> -->

	<div class="flex items-start justify-center gap-7 mb-1 mt-10">
		<div class="text-7xl leading-none ml-10">⚠️</div>
		<div>
			<h1 class="text-4xl font-extrabold tracking-wide text-gray-900">
				STAY SAFE, BE VIGILANT ALWAYS.
			</h1>

			<p class="mt-3 text-gray-700 text-lg leading-loose max-w-[600px]">
				Before using this machine, if you suspect it has been tampered with or if
				there are suspicious individuals nearby, please choose another machine or
				use it another time.<br />
				Please contact <span class="font-semibold">1800 363 3333</span> for any security concern.
			</p>
			<br>

			<div class="mb-5">
				<h1 class="text-4xl font-extrabold tracking-wide text-gray-900">
					时刻保持警惕
				</h1>
				<p class="mt-3 text-gray-700 text-lg leading-loose max-w-[600px]">
					在使用提款机之前，如果发现提款机曾被人动过手脚或附近有任何可疑人物，
					请选择改用其他地点的提款机或改在其他时间前来使用。<br />
					若有任何保安方面的疑虑，请拨电
					<span class="font-semibold">1800 363 3333</span> 查询。
				</p>
			</div>
		</div>
	</div>

	<!-- Action Buttons -->
	<div class="flex justify-center gap-10 mt-10">

		<button
			onclick={() => goto('/withdraw')}
			class="w-60 h-25 rounded-2xl bg-linear-to-b from-[#353b4b] to-[#1f2330]
			text-white text-lg font-medium shadow-lg hover:brightness-110 transition
			flex flex-col items-center justify-center"
		>
			Withdraw cash
			<span class="text-sm text-gray-300 mt-1">using OCBC app</span>
		</button>

		<button
			onclick={() => goto('/deposit')}
			class="w-60 h-25 rounded-2xl bg-linear-to-b from-[#353b4b] to-[#1f2330]
			text-white text-lg font-medium shadow-lg hover:brightness-110 transition
			flex flex-col items-center justify-center"
		>
			Non-Card / Business
			<span class="text-sm text-gray-300 mt-1">Deposit Services</span>
		</button>

		<button
			onclick={() => goto('/')}
			class="w-60 h-25 rounded-2xl bg-linear-to-b from-[#353b4b] to-[#1f2330]
			text-white text-lg font-medium shadow-lg hover:brightness-110 transition
			flex flex-col items-center justify-center"
		>
			Government Payout
		</button>
	</div>
<!-- </div> -->

