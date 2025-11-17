<script>
  // Optional: Could use this later for transitions
</script>

<!-- Fullscreen ATM Machine -->
<div class="w-screen h-screen bg-[#1c2737] flex items-center justify-center">

  <!-- ATM Body -->
  <div
    class="bg-[#111a27] rounded-3xl shadow-2xl border border-gray-700 
           w-[90%] max-w-[1000px] h-[85%] max-h-[680px]
           flex flex-col items-center relative">

    <!-- OCBC Top Red Bar -->
    <div class="w-full h-20 bg-red-600 rounded-t-3xl flex items-center justify-center text-white text-3xl font-semibold tracking-wide">
      OCBC
    </div>

    <!-- Main ATM Screen -->
    <div class="flex-1 w-full bg-gradient-to-b from-[#0e1a33] to-[#091020] 
                rounded-b-3xl px-10 py-10 flex flex-col items-center text-center relative">

      <!-- User Icon (Top Right) -->
      <div class="absolute top-6 right-6 flex items-center gap-3">
        <div class="w-12 h-12 bg-blue-500 rounded-full text-white flex items-center justify-center text-2xl">
          👤
        </div>
        <p class="text-white text-sm opacity-90">Welcome, Mike</p>
      </div>

      <!-- Loading Spinner -->
      <div class="flex flex-col items-center mt-12">
        <div class="w-14 h-14 border-4 border-green-500 border-t-transparent rounded-full animate-spin mb-6"></div>

        <h2 class="text-2xl text-white font-semibold mb-2">
          Withdrawing in Process...
        </h2>

        <p class="text-gray-400 text-sm mb-6">Please wait</p>

        <!-- Loading dots -->
        <div class="flex gap-2">
          <div class="h-3 w-3 bg-green-500 rounded-full animate-bounce"></div>
          <div class="h-3 w-3 bg-green-500 rounded-full animate-bounce delay-150"></div>
          <div class="h-3 w-3 bg-green-500 rounded-full animate-bounce delay-300"></div>
        </div>
      </div>
    </div>

    <!-- ATM Bottom Section -->
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
