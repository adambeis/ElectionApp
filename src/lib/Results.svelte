<script>
  import { onMount } from "svelte";
  import { candidates } from "../store/candidates.js";
  import { contract } from "../store/election";
  import {
    registeredCandidates,
    registeredVoters,
    voteCount,
    start,
    end,
    timeLeft,
  } from "../store/store.js";
  import Candidate from "./Candidate.svelte";

  $: noVoters = 100 - ($voteCount * 100) / $registeredVoters || 0;
  let ds;
  let de;

  onMount(() => {
    getData();
  });

  const ChanelRand = () => {
    return Math.floor(Math.random() * (256 + 1));
  };

  const getRdmColors = () => {
    return (
      "rgb(" + ChanelRand() + "," + ChanelRand() + "," + ChanelRand() + ")"
    );
  };

  const getData = async () => {
    $registeredCandidates = parseInt(
      await $contract.registeredCandidates.call()
    );

    $registeredVoters = parseInt(await $contract.registeredVoters.call());

    $voteCount = parseInt(await $contract.voteCount.call());

    $timeLeft = parseInt(await $contract.getTimeLeft());

    $start = parseInt(await $contract.start.call());
    ds = new Date(0);
    ds.setUTCSeconds($start);

    $end = parseInt(await $contract.end.call());
    de = new Date(0);
    de.setUTCSeconds($end);
  };
</script>

<section class="w-full h-full">
  <div class="overflow-scroll">
    <div>
      <h1 class="mt-6 text-3xl font-bold">Vote count</h1>
      <div class="flex mt-5">
        <div class="m-auto flex">
          {#each $candidates as candidate, i}
            <Candidate {candidate} color={getRdmColors()} />
          {/each}
        </div>
      </div>
    </div>

    <div>
      <div>
        <p class="mt-8 text-3xl font-bold">Election Day starts:</p>
        {#if ds}
          <p class="mt-4 text-xl">{ds}</p>
        {/if}
      </div>
      <div>
        <p class="mt-8 text-3xl font-bold">Election Day ends:</p>
        {#if de}
          <p class="mt-4 text-xl">{de}</p>
        {/if}
      </div>
    </div>

    <div>
      <p class="mt-8 text-3xl font-bold">Did not vote</p>
      <p class="mt-4 text-xl">{noVoters.toString().slice(0, 4)}%</p>
    </div>
  </div>
</section>
