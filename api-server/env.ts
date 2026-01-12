import "dotenv/config";

function getEnvOrThrow(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`${key} environment variable not set`);
  }
  return value;
}

/**
 * Environment variables with lazy evaluation.
 * Each property is a getter that only throws if accessed and the env var is not set.
 * This allows unit tests to import this module without errors if they don't use env vars.
 */
const env = {
  get PORT(): number | undefined {
    return process.env.PORT ? +process.env.PORT : undefined;
  },
  get JWT_SECRET(): string {
    return getEnvOrThrow("JWT_SECRET");
  },
  get JWT_ISSUER(): string {
    return getEnvOrThrow("JWT_ISSUER");
  },
  get DATABASE_URL(): string {
    return getEnvOrThrow("DATABASE_URL");
  },
  get ABLY_API_KEY(): string {
    return getEnvOrThrow("ABLY_API_KEY");
  },
};

export default env;
