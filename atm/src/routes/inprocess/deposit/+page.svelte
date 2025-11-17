<script>
  import { goto } from "$app/navigation";
  export let next = "../withdraw-completion/deposit";
  export let delay = 3000; 

  setTimeout(() => goto(next), delay);
</script>

<div class="flex flex-col items-center mt-12">
  <div class="w-14 h-14 border-4 border-green-500 border-t-transparent rounded-full animate-spin mb-6"></div>

  <h2 class="text-2xl text-white font-semibold mb-2">
    Depositing in Process...
  </h2>

  <p class="text-gray-400 text-sm mb-6">Please wait</p>

  <div class="flex gap-2">
    <div class="h-3 w-3 bg-green-500 rounded-full animate-bounce"></div>
    <div class="h-3 w-3 bg-green-500 rounded-full animate-bounce delay-150"></div>
    <div class="h-3 w-3 bg-green-500 rounded-full animate-bounce delay-300"></div>
  </div>
</div>
