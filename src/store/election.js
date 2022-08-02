import { writable } from "svelte/store";

export const contract = writable(null);
export const selectedAccount = writable("");
export const connected = writable(false);
