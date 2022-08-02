import { writable } from "svelte/store";

export const registeredCandidates = writable(0);
export const registeredVoters = writable(0);
export const voteCount = writable(0);

export const start = writable(0);
export const end = writable(0);
export const timeLeft = writable(0);
