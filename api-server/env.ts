import "dotenv/config";

function getEnvOrThrow(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`${key} environment variable not set`);
  }
  return value;
}

/**
 * Provides typed environment variables. Throws when
 * a non-optional environment variable is accessed.
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
