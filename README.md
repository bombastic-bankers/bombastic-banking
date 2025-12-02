# Bombastic Banking

Bombastic Banking is an accessible digital banking prototype. It consists of a "touchless ATM" system that allows ATM users to interact with the ATM directly from the banking app, eliminating any need to touch the ATM screen. We plan to integrate an agentic voice assistant in the near future.

For this prototype, we have no cash-related hardware, so all cash transactions are simulated.

## Development

Follow the `.env.example` file for the API server or ATM (depending on what you want to run).

To run the API server or ATM, `cd` into the corresponding folder and run the following.

```
$ npm run dev
```

To generate an `ATM_TOKEN` for the ATM, run the following from `api-server/`.

```
$ npm run gen-atm-token --id=<atmId>  # <atmId> must be an integer
```

To use the deployed API server with your ATM running locally, set the following in `atm/.env`.

```
API_SERVER_URL="https://bombastic-bankers.vercel.app"
```

Refer to `docs/` for the system's functional requirements and architecture specification.