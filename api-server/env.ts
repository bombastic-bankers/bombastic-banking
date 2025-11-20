import "dotenv/config";

function getEnvOrThrow(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`${key} environment variable not set`);
  }
  return value;
}

export const PORT = process.env.PORT ? +process.env.PORT : undefined;
export const JWT_SECRET = getEnvOrThrow("JWT_SECRET");
export const DATABASE_URL = getEnvOrThrow("DATABASE_URL");
export const ABLY_API_KEY = getEnvOrThrow("ABLY_API_KEY");
