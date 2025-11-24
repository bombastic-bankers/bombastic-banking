<script lang="ts">
    import { goto } from '$app/navigation';

    // Data comes from +page.js loader
    export let data;

    const next = data.next;

    setTimeout(() => {
        goto(next);
    }, 4000);
</script>

<div class="w-full h-full bg-white rounded-xl flex items-center justify-center">
    <p class="text-2xl font-semibold text-gray-800 text-center">
        Please refer to your phone for instructions
    </p>
</div>
