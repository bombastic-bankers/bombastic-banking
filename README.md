# Bombastic Banking

Bombastic Banking is an accessible digital banking prototype. It consists of a "touchless ATM" system that allows ATM users to interact with the ATM directly from the banking app, eliminating any need to touch the ATM screen. We plan to integrate an agentic voice assistant in the near future.

For this prototype, we have no cash-related hardware, so all cash transactions are simulated.

## Development

**To set up and run the API server,**

1. Create a `api-server/.env` following `api-server/.env.example`.

2. ```
   $ cd api-server
   $ npm i
   $ npm run seed  # Seed database with internal accounts
   $ npm run dev
   ```

**To set up and run the ATM,**

1. Create a `atm/.env` following `atm/.env.example`.

2. ```
   $ cd api-server
   $ npm i
   $ npm run gen-atm-token --id=123  # Use any integer
   $ cd ..
   ```

3. Copy the output to the `ATM_TOKEN` in `atm/.env`.

4. If you wish to use the deployed API server with your ATM running locally, set the following in `atm/.env`:

   ```
   API_SERVER_URL="https://bombastic-bankers.vercel.app"
   ```

5. ```
   $ cd atm
   $ npm i
   $ npm run dev
   ```

**To update the database with a modified schema,**

1. ```
   $ cd api-server
   $ npx drizzle-kit push
   ```

Refer to `docs/` for the system's functional requirements and architecture specification.
