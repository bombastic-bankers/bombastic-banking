import { createContext } from 'svelte';

type SSEListener = (event: MessageEvent) => void;

export const [getSSEContext, setSSEContext] =
	createContext<(event: string, listener: SSEListener) => () => void>();
