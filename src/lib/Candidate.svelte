<script>
  import { onMount } from "svelte";
  import { tweened } from "svelte/motion";
  import { registeredVoters } from "../store/store.js";
  import { contract } from "../store/election";
  export let candidate;
  export let color;

  const width = tweened(0);
  let voteCount = 0;
  onMount(() => {
    updateWidth();
  });

  const updateWidth = async () => {
    $registeredVoters = parseInt(await $contract.registeredVoters.call());
    if ($registeredVoters > 0) {
      voteCount = (candidate.voteCount * 100) / $registeredVoters;
      width.set(voteCount);
    }
  };
</script>

<div class="p-4 rounded">
  <div class="h-40 flex items-end">
    <div
      class="flex items-end w-32"
      style="height: {$width}%; background-color: {color}"
    >
      <div class="text.center w-full">
        {voteCount.toString().slice(0, 4)} %
      </div>
    </div>
  </div>
  <img class="w-20 h-24 mt-3 m-auto rounded" src={candidate.url} alt="" />
  <p class="mt-3 font-semibold">
    {candidate.name}
  </p>
</div>
