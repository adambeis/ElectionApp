<script>
  import { contract } from "../store/election";
  import { create as ipfsHttpClient } from "ipfs-http-client";

  const client = ipfsHttpClient({ url: "https://ipfs.infura.io:5001/api/v0" });

  let fileUrl;
  let fileValue = null;
  let candidateName;
  let voterName;
  let voterAddress;
  let time;

  const date = new Date();

  async function onChange(e) {
    const file = e.target.files[0];
    try {
      const added = await client.add(file, {
        progress: (prog) => console.log(`received: ${prog}`),
      });
      fileUrl = `https://ipfs.infura.io/ipfs/${added.path}`;
    } catch (error) {
      console.log("Error uploading file: ", error);
    }
  }

  const handleAddCandidate = async () => {
    if (fileUrl && candidateName)
      try {
        const tx = await $contract.addCandidate(candidateName, fileUrl);
        const receipt = await tx.wait();
        candidateName = "";
        fileUrl = "";
        fileValue = "";
        alert("Candidate added");
        console.log("receipt", receipt);
      } catch (error) {
        console.log(error);
      }
  };

  const handleAddVoter = async () => {
    try {
      const tx = await $contract.addVoter(voterName, voterAddress);
      const receipt = await tx.wait();
      voterName = "";
      voterAddress = "";
      alert("Voter added");
      console.log("receipt", receipt);
    } catch (error) {
      alert("Error on adding a candidate");
      console.log(error);
    }
  };

  const handleStartElection = async () => {
    try {
      const tx = await $contract.startElection(time);
      const receipt = await tx.wait();
      time = "";
      alert("Election is active and start now");
      console.log("receipt", receipt);
    } catch (error) {
      alert("Error on adding a candidate");
      console.log(error);
    }
  };

  const handleResetElection = async () => {
    try {
      const tx = await $contract.resetElection();
      const receipt = await tx.wait();
      alert("Election is reset.");
      console.log("receipt", receipt);
    } catch (error) {
      alert("Error on reset election");
      console.log(error);
    }
  };
</script>

<div class="w-full space-y-2">
  <div
    class="grid md:w-3/6 m-auto space-y-2 border border-1 border-gray-300 p-4 rounded"
  >
    {#if fileUrl}
      <img class="rounded m-auto" src={fileUrl} alt="" />
    {/if}
    <input
      type="file"
      name="Asset"
      class="my-4"
      on:change={onChange}
      value={fileValue}
    />
    <input
      type="text"
      placeholder="name"
      class="border border-1 border-gray-300 rounded px-1"
      bind:value={candidateName}
    />
    <button
      on:click={handleAddCandidate}
      class="m-auto bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 hover:border-black shadow rounded"
      >Add Candidate</button
    >
  </div>

  <div
    class="grid md:w-3/6 m-auto space-y-2 border border-1 border-gray-300 p-4 rounded"
  >
    <input
      type="text"
      placeholder="name"
      class="border border-1 border-gray-300 rounded px-1"
      bind:value={voterName}
    />
    <input
      type="text"
      placeholder="address"
      class="border border-1 border-gray-300 rounded px-1"
      bind:value={voterAddress}
    />
    <button
      on:click={handleAddVoter}
      class="m-auto bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 hover:border-black shadow rounded"
      >Add Voter</button
    >
  </div>

  <div
    class="grid md:w-3/6 m-auto space-y-2 border border-1 border-gray-300 p-4 rounded"
  >
    <div>
      <p>Start(Now)</p>
      <p>{date}</p>
    </div>
    <div>
      <p>End(time on minutes)</p>
      <input
        type="text"
        placeholder="e.g. 180"
        class="w-full border border-1 border-gray-300 rounded px-1"
        bind:value={time}
      />
    </div>
    <button
      on:click={handleStartElection}
      class="m-auto bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 hover:border-black shadow rounded"
      >Start Election</button
    >
  </div>

  <div
    class="grid md:w-3/6 m-auto space-y-2 border border-1 border-gray-300 p-4 rounded"
  >
    <button
      on:click={handleResetElection}
      class="m-auto bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 hover:border-black shadow rounded"
      >Reset Election</button
    >
  </div>
</div>
