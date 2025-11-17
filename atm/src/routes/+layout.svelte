<!-- <script lang="ts">
	import '../app.css';
	import favicon from '$lib/assets/favicon.svg';

	let { children } = $props();
</script>

<svelte:head>
	
</svelte:head>

{@render children()} -->



<script>
  import '../app.css';
	import favicon from '$lib/assets/favicon.svg';

	let { children } = $props();
</script>

<svelte:head>
  <title>ATM Dashboard</title>
  <link rel="icon" href={favicon} />
</svelte:head>

<!-- Fullscreen Machine Background -->
<div class="w-screen h-screen bg-[#111a27] flex items-center justify-center">

  <!-- ATM Frame -->
  <div
    class="bg-[#0c1525] shadow-xl rounded-3xl border border-gray-700
           w-[90%] max-w-[900px] h-[80%]
           flex flex-col items-center relative">

    <!-- OCBC Top Bar -->
    <div class="w-full h-20 bg-red-600 rounded-t-3xl flex items-center justify-center
                text-white text-3xl font-semibold tracking-wide">
      OCBC
    </div>

    <!-- Main Screen Area -->
	<div class="flex-1 w-full flex flex-col items-center text-center px-8 pt-2 pb-10 relative">
	<!-- <div class="flex-1 w-full flex flex-col items-center text-center px-8 pt-4 pb-10 relative"> -->


      <!-- User Icon -->
      <div class="absolute top-6 right-6 flex items-center gap-3">
        <div class="w-12 h-12 bg-blue-500 rounded-full text-white flex items-center justify-center text-2xl">
          👤
        </div>
        <p class="text-white/80 text-sm">Welcome, Mike</p>
      </div>

      <!-- Page-Specific Content -->
      <div class="pt-20 w-full h-full flex flex-col items-center">
        {@render children()}
      </div>
    </div>

    <!-- Bottom Vents + Card Slot -->
    <div class="absolute bottom-6 w-full flex flex-col items-center">

      <!-- Vents -->
      <div class="flex justify-between w-[60%] text-gray-600 mb-3">
        <div class="space-y-1">
          <div class="h-1 w-8 bg-gray-700 rounded"></div>
          <div class="h-1 w-8 bg-gray-700 rounded"></div>
          <div class="h-1 w-8 bg-gray-700 rounded"></div>
        </div>
        <div class="space-y-1">
          <div class="h-1 w-8 bg-gray-700 rounded"></div>
          <div class="h-1 w-8 bg-gray-700 rounded"></div>
          <div class="h-1 w-8 bg-gray-700 rounded"></div>
        </div>
      </div>

      <!-- Card Slot -->
      <div class="h-5 w-64 bg-black rounded-lg shadow-inner"></div>
    </div>

  </div>
</div>
