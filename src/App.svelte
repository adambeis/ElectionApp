<script>
  import { contract, selectedAccount, connected } from "./store/election.js";
  import electionContract from "./contracts/Election.json";
  import { voter } from "./store/voter.js";
  import { timeLeft } from "./store/store.js";
  import Candidates from "./lib/Candidates.svelte";
  import Results from "./lib/Results.svelte";
  import Admin from "./lib/Admin.svelte";
  import { onMount } from "svelte";
  import { ethers } from "ethers";

  let tab = 1;
  let isAdmin = false;

  $: $contract && getAdmin();

  $: myAccount = $selectedAccount ? getSelectedAcc() : "";
  $: !isAdmin && (tab = 1);

  onMount(() => {
    connectWallet();
  });

  const changedAccount = (accounts) => {
    console.log("account change");
    window.location.reload();
  };

  const changedChainId = () => {
    window.location.reload();
    console.log("network change");
  };

  const connectWallet = async () => {
    let newProvider = new ethers.providers.Web3Provider(window.ethereum, "any");
    await newProvider.send("eth_requestAccounts", []);

    const { provider: ethereum } = newProvider;

    let newSigner = newProvider.getSigner();

    $selectedAccount = await newSigner.getAddress();

    // @ts-ignore
    ethereum.on("accountsChanged", changedAccount);
    //ethereum.removeListener('accountsChanged', changedAccount);

    // @ts-ignore
    ethereum.on("chainChanged", changedChainId);

    $contract = new ethers.Contract(
      electionContract.networks[4].address,
      electionContract.abi,
      newSigner
    );

    $connected = true;
  };

  const getVoter = async () => {
    $voter = null;
    $timeLeft = parseInt(await $contract.getTimeLeft);
  };

  const getAdmin = async () => {
    let admin = await $contract.admin.call();
    if ($selectedAccount == admin) isAdmin = true;
    else isAdmin = false;
  };

  const changeTab = (tabOption) => {
    tab = tabOption;
  };

  const getSelectedAcc = () => {
    return (
      $selectedAccount.slice(0, 4) +
      " ... " +
      $selectedAccount.slice(
        $selectedAccount.length - 4,
        $selectedAccount.length
      )
    );
  };
</script>

<main class="overflow-hidden">
  {#if !$connected}
    <p>App is not connected</p>
  {:else}
    <div class="grid grid-cols-3">
      <div class="col-start-2 place-self-center">
        <div class="justify-self-center inline-flex">
          <button
            on:click={() => changeTab(1)}
            class="w-24 bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 hover:border-black shadow rounded-l"
          >
            Vote
          </button>
          <button
            on:click={() => changeTab(2)}
            class="w-24 bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 hover:border-black shadow rounded-r"
          >
            Results
          </button>
        </div>
      </div>
      <div>
        <div class="place-self-center">
          <div class="justify-self-center inline-flex space-x-2">
            {#if isAdmin}
              <button
                on:click={() => changeTab(0)}
                class="m-auto bg-red-400 hover:bg-red-800 hover:text-white text-gray-800 font-semibold py-2 px-4 border border-gray-400 hover:border-black shadow rounded"
              >
                Admin
              </button>
            {/if}
            <p class="font-semibold">
              {myAccount}
            </p>
          </div>
        </div>
      </div>
    </div>
    {#if tab == 0}
      <Admin />
    {:else if tab == 1}
      <Candidates />
    {:else if tab == 2}
      <Results />
    {:else}
      <p>Not Found</p>
    {/if}
  {/if}
</main>

<style>
  :root {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen,
      Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
  }

  main {
    text-align: center;
    padding: 1em;
    margin: 0 auto;
  }

  p {
    max-width: 14rem;
    margin: 1rem auto;
    line-height: 1.35;
  }

  @media (min-width: 480px) {
    p {
      max-width: none;
    }
  }
</style>
