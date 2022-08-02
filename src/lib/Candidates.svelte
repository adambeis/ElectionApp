<script>
  import { contract, selectedAccount } from "../store/election";
  import { candidates, candidatesCount } from "../store/candidates.js";
  import { voter } from "../store/voter.js";
  import { timeLeft } from "../store/store.js";

  $: $contract && getCandidates();

  const getCandidates = async () => {
    $candidates = [];
    $candidatesCount = await $contract.registeredCandidates.call();
    for (let i = 1; i <= $candidatesCount; i++) {
      let candidate = await $contract.candidates(i);
      $candidates = [...$candidates, candidate];
    }
  };

  const isAllowed = async () => {
    let voterIndex = await $contract.getVoterIndex();
    if (voterIndex) return true;
    return false;
  };

  const vote = async (candidateId) => {
    $timeLeft = await $contract.getTimeLeft();
    $voter = await $contract.voters(1);

    if ($timeLeft == 0) {
      alert("Election is not active");
      return;
    }
    let isValid = await isAllowed();
    if (!isValid) {
      alert("Voter not allowed to vote");
      return;
    }
    if ($voter.vote) {
      alert("Voter already voted");
      return;
    }

    try {
      const tx = await $contract.vote(candidateId);
      const receipt = await tx.wait();
      alert("Success");
      getCandidates();
      console.log("receipt", receipt);
    } catch (error) {
      alert("Error: voter already vote");
      console.log(error);
    }
  };
</script>

<section class="w-full h-full">
  <h1 class="mt-5 text-3xl font-bold">Candidates</h1>
  <div class="flex mt-5">
    {#each $candidates as candidate}
      <div class="p-4 m-auto border border-black rounded">
        <img class="w-48 h-64 rounded" src={candidate.url} alt="" />
        <p class="text-xl mt-3">
          {candidate.name}
        </p>
        <button
          class="mt-5 min-w-full bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 hover:border-black rounded shadow"
          on:click={() => vote(candidate.candidateId)}
          disabled={$voter.vote}>Vote</button
        >
      </div>
    {/each}
  </div>
</section>
