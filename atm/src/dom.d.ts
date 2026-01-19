import type { EventHandler } from "svelte/elements";

type WithdrawEvent = CustomEvent<{ amount: number }>;

declare module "svelte/elements" {
    interface DOMAttributes<T extends EventTarget> {
        onwithdraw?: EventHandler<WithdrawEvent, T> | undefined | null;
        ondepositstart?: EventHandler<Event, T> | undefined | null;
        ondepositcount?: EventHandler<Event, T> | undefined | null;
        ondepositconfirm?: EventHandler<Event, T> | undefined | null;
        ondepositcancel?: EventHandler<Event, T> | undefined | null;
        onexit?: EventHandler<Event, T> | undefined | null;
    }
}