<script>
  import { goto } from "$app/navigation";

  function fomePage() {
    goto('/');
  }

  function exit() {
    goto('/exit');
  }
</script>

<div class="w-18 h-18 rounded-full border-4 border-green-500 flex items-center justify-center">
  <div class="w-6 h-12 border-b-4 border-r-4 border-green-500 rotate-45"></div>
</div>
<h2 class="text-white text-2xl font-semibold mt-6">Withdraw Complete!</h2>
<p class="text-gray-400 mt-1">Thank you for using OCBC Bank ATM</p>

<button on:click={fomePage} class="mt-5 px-8 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-lg">
  New Transaction
</button>

<button on:click={exit} class="mt-4 px-8 py-3 bg-white text-red-500 border border-red-300 rounded-lg text-lg">
  Take Out Card & Exit
</button>
