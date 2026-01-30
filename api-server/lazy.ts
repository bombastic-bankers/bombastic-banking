/**
 * Creates a lazy-initialized object.
 */
export default function lazy<T extends object>(fn: () => T): T {
    let instantiated = false;
    let value: T | null = null;
    return new Proxy({} as T, {
        get(_, prop) {
            if (!instantiated) {
                value = fn();
                instantiated = true;
            }
            return Reflect.get(value!, prop);
        },
    });
}