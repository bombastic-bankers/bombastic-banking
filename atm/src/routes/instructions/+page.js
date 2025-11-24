export function load({ url }) {
    return {
        next: url.searchParams.get('next') ?? '/'
    };
}
