<script lang="ts">
	import { goto } from '$app/navigation';
</script>

<svelte:window
	onwithdraw={(event) => goto(`/withdraw?amount=${event.detail.amount}`)}
	ondepositstart={() => goto('/deposit')}
/>

<div class="mt-10 mb-1 flex items-start justify-center gap-7">
	<div class="ml-10 text-7xl leading-none">⚠️</div>
	<div>
		<h1 class="text-4xl font-extrabold tracking-wide text-gray-900">
			STAY SAFE, BE VIGILANT ALWAYS.
		</h1>

		<p class="mt-3 max-w-[600px] text-lg leading-loose text-gray-700">
			Before using this machine, if you suspect it has been tampered with or if there are suspicious
			individuals nearby, please choose another machine or use it another time.<br />
			Please contact <span class="font-semibold">1800 363 3333</span> for any security concern.
		</p>
		<br />

		<div class="mb-5">
			<h1 class="text-4xl font-extrabold tracking-wide text-gray-900">时刻保持警惕</h1>
			<p class="mt-3 max-w-[600px] text-lg leading-loose text-gray-700">
				在使用提款机之前，如果发现提款机曾被人动过手脚或附近有任何可疑人物，
				请选择改用其他地点的提款机或改在其他时间前来使用。<br />
				若有任何保安方面的疑虑，请拨电
				<span class="font-semibold">1800 363 3333</span> 查询。
			</p>
		</div>
	</div>
</div>

<!-- Action Buttons -->
<div class="mt-10 flex justify-center gap-10">
	<a
		href="/withdraw"
		class="flex h-25 w-60 flex-col items-center justify-center
			rounded-2xl bg-linear-to-b from-[#353b4b] to-[#1f2330] text-lg font-medium
			text-white shadow-lg transition hover:brightness-110"
	>
		Withdraw cash
		<span class="mt-1 text-sm text-gray-300">using OCBC app</span>
	</a>

	<a
		href="/deposit"
		class="flex h-25 w-60 flex-col items-center justify-center
			rounded-2xl bg-linear-to-b from-[#353b4b] to-[#1f2330] text-lg font-medium
			text-white shadow-lg transition hover:brightness-110"
	>
		Non-Card / Business
		<span class="mt-1 text-sm text-gray-300">Deposit Services</span>
	</a>

	<a
		href="/"
		class="flex h-25 w-60 flex-col items-center justify-center
			rounded-2xl bg-linear-to-b from-[#353b4b] to-[#1f2330] text-lg font-medium
			text-white shadow-lg transition hover:brightness-110"
	>
		Government Payout
	</a>
</div>
