<script lang="ts">
    import { goto } from '$app/navigation';
    import { page } from '$app/state';

    const amount = +page.url.searchParams.get('amount')!;

    // Redirect after 4s
    setTimeout(() => {
        goto('/deposit/received?amount=' + amount);
    }, 4000);
</script>

<div class="w-full h-full bg-[#e5e7eb] rounded-xl flex items-center justify-center">
    <p class="text-2xl font-semibold text-gray-800 text-center">
        Please refer to your phone for instructions
    </p>
</div>
