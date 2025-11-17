<script>
  import { page } from "$app/stores";
  $: amount = $page.url.searchParams.get("amount") || 0;

  import { goto } from "$app/navigation";
  export let next = "../withdraw-completion/withdraw";
  export let delay = 3000; // milliseconds

  setTimeout(() => goto(next), delay);
</script>

      <div class="w-28 h-20 flex items-center justify-center mb-6">
        <span class="text-5xl">💵</span>
      </div>

      <!-- Main Text -->
      <h2 class="text-3xl text-white font-semibold mb-2">
        Cash Ready!
      </h2>

      <p class="text-gray-300 text-lg mb-3">
        Please take your cash
      </p>

      <!-- Amount -->
      <p class="text-green-400 text-lg mb-8">
        Amount: ${amount}
      </p>

      <!-- Instruction -->
      <p class="text-gray-400 text-sm">
        Take out the cash whenever you are ready
      </p>
