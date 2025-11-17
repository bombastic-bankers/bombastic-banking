<script>
  import { goto } from "$app/navigation";
  export let title = "Select Amount";
  export let subtitle = "Choose an amount";
  export let action = "withdraw";

  /**
	 * @param {number} amount
	 */
  function selectAmount(amount) {
  if (action === "withdraw") {
    goto(`../inprocess/withdraw?amount=${amount}`);
  } else if (action === "deposit") {
    goto(`../ready/deposit?amount=${amount}`);
  }
}
</script>

<!-- WRAPPER — shift whole content upward -->
<div class="-mt-6 flex flex-col items-center w-full">

  <!-- PAGE ICON -->
  <div class="w-20 h-20 bg-blue-500/20 border border-blue-400 rounded-2xl 
              flex items-center justify-center text-blue-400 text-4xl mb-6">
    💳
  </div>

  <!-- TITLE -->
  <h2 class="text-3xl text-white font-semibold mb-2">{title}</h2>

  <p class="text-gray-400 text-base mb-2">
    {subtitle}
  </p>

  <!-- AMOUNT BUTTON GRID -->
  <div class="grid grid-cols-3 gap-6">
    <button on:click={() => selectAmount(50)} class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">$50</button>
    <button on:click={() => selectAmount(100)} class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">$100</button>
    <button on:click={() => selectAmount(200)} class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">$200</button>
    <button on:click={() => selectAmount(500)} class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">$500</button>
    <button on:click={() => selectAmount(1000)} class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">$1000</button>
    <button on:click={() => selectAmount(2000)} class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">$2000</button>
  </div>

</div>

<button
  on:click={() => history.back()}
  class="absolute top-6 left-6 
         px-4 py-2 bg-white/90 text-gray-800 
         rounded-lg shadow hover:bg-gray-100 transition"
>
  ← Back
</button>

