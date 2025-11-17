<!-- FULLSCREEN ATM MACHINE -->
<div class="w-screen h-screen bg-[#1c2737] flex items-center justify-center">

  <!-- ATM Body -->
  <div
    class="bg-[#111a27] rounded-3xl shadow-2xl border border-gray-700 
           w-[90%] max-w-[1000px] h-[85%] max-h-[680px]
           flex flex-col items-center relative">

    <!-- Top Red Bar -->
    <div class="w-full h-20 bg-red-600 rounded-t-3xl flex items-center justify-center text-white text-3xl font-semibold tracking-wide">
      OCBC
    </div>

    <!-- ATM Screen -->
    <div class="flex-1 w-full bg-gradient-to-b from-[#0e1a33] to-[#091020]
                rounded-b-3xl px-10 py-10 flex flex-col items-center text-center relative">

      <!-- User Icon (top right) -->
      <div class="absolute top-6 right-6 flex items-center gap-3">
        <div class="w-12 h-12 bg-blue-500 rounded-full text-white flex items-center justify-center text-2xl">
          👤
        </div>
      </div>

      <!-- Deposit Icon -->
      <div class="w-20 h-20 bg-blue-500/20 border border-blue-400 rounded-2xl flex items-center justify-center text-blue-400 text-4xl mb-6">
        💳
      </div>

      <!-- Title -->
      <h2 class="text-3xl text-white font-semibold mb-2">
        Select Deposit Amount
      </h2>

      <p class="text-gray-400 text-base mb-10">
        Choose the amount you want to deposit
      </p>

      <!-- Deposit Buttons Grid -->
      <div class="grid grid-cols-3 gap-6">

        <button class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">
          $50
        </button>

        <button class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">
          $100
        </button>

        <button class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">
          $200
        </button>

        <button class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">
          $500
        </button>

        <button class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">
          $1000
        </button>

        <button class="px-8 py-4 text-lg bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">
          $2000
        </button>

      </div>

      <div class="relative w-full h-full">

        <!-- BACK BUTTON -->
        <a
          href="/"
          class="absolute bottom-5 left-1/2 -translate-x-1/2 
                px-6 py-2 bg-white text-gray-700 rounded-xl shadow 
                hover:bg-gray-100 transition flex items-center gap-2"
        >
          ← Back
        </a>
      </div>


        

    </div>

    <!-- Bottom Vents + Card Slot -->
    <div class="absolute bottom-6 w-full flex flex-col items-center">

      <!-- Vents -->
      <div class="flex justify-between w-[65%] text-gray-600 mb-3">
        <div class="space-y-1">
          <div class="h-1 w-9 bg-gray-700 rounded"></div>
          <div class="h-1 w-9 bg-gray-700 rounded"></div>
          <div class="h-1 w-9 bg-gray-700 rounded"></div>
        </div>
        <div class="space-y-1">
          <div class="h-1 w-9 bg-gray-700 rounded"></div>
          <div class="h-1 w-9 bg-gray-700 rounded"></div>
          <div class="h-1 w-9 bg-gray-700 rounded"></div>
        </div>
      </div>

      <!-- Card Slot -->
      <div class="h-5 w-72 bg-black rounded-lg shadow-inner"></div>
    </div>

  </div>
</div>
