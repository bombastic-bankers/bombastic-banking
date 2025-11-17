<svelte:head>
  <title>Dashboard</title>
</svelte:head>

<!-- ATM FULLSCREEN MACHINE -->
<div class="w-screen h-screen bg-[#111a27] flex items-center justify-center">

  <!-- ATM SCREEN (now responsive but taking the full machine height) -->
  <div class="bg-[#0c1525] shadow-xl rounded-3xl border border-gray-700 
              w-[90%] max-w-[900px] h-[80%]
              flex flex-col items-center relative">

    <!-- OCBC Top Bar -->
    <div class="w-full h-20 bg-red-600 rounded-t-3xl flex items-center justify-center text-white text-3xl font-semibold tracking-wide">
      OCBC
    </div>

    <!-- Main ATM Screen -->
    <div class="flex-1 w-full flex flex-col items-center justify-start text-center px-8 py-10">

      <!-- User Icon -->
      <div class="w-24 h-24 bg-blue-500 rounded-full flex items-center justify-center text-white text-5xl mb-4">
        <!-- 👤 -->
      </div>

      <h2 class="text-3xl text-white font-semibold mb-2">Welcome, Mike!</h2>
      <p class="text-gray-400 text-lg mb-10">Please select a transaction</p>

      <div class="flex gap-8">
        <a
          href="/withdraw"
          class="px-10 py-4 text-xl bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition"
        >
          Withdraw
        </a>


        <a
          href="/deposit"
          class="px-10 py-4 text-xl bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition"
        >
          Deposit
        </a>
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
