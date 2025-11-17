<script>
  import { page } from "$app/stores";
  $: amount = $page.url.searchParams.get("amount") || 0;

  import { goto } from "$app/navigation";
  export let next = "../inprocess/deposit";
  export let delay = 3000; 

  setTimeout(() => goto(next), delay);
</script>

      <div class="w-28 h-20 flex items-center justify-center mb-6">
        <span class="text-5xl">💵</span>
      </div>

      <!-- Main Text -->
      <h2 class="text-3xl text-white font-semibold mb-2">
        Insert Your Cash
      </h2>

      <p class="text-gray-300 text-lg mb-3">
        Please deposit your money
      </p>

      <!-- Amount -->
      <p class="text-green-400 text-lg mb-8">
        Amount: ${amount}
      </p>

      <!-- Instruction -->
      <p class="text-gray-400 text-sm">
        Deposit the money whenever you are ready
      </p>
