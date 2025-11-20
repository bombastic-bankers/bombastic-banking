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

export const PUSHER_APP_ID = getEnvOrThrow("PUSHER_APP_ID");
export const PUSHER_KEY = getEnvOrThrow("PUSHER_KEY");
export const PUSHER_SECRET = getEnvOrThrow("PUSHER_SECRET");
export const PUSHER_CLUSTER = getEnvOrThrow("PUSHER_CLUSTER");

export const SERVER_SELF_AUTH_KEY = getEnvOrThrow("SERVER_SELF_AUTH_KEY");
export const ABLY_API_KEY = getEnvOrThrow("ABLY_API_KEY");
