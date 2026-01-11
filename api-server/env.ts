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
export const JWT_ISSUER = getEnvOrThrow("JWT_ISSUER");
export const DATABASE_URL = getEnvOrThrow("DATABASE_URL");
export const ABLY_API_KEY = getEnvOrThrow("ABLY_API_KEY");

export const EMAIL_USER = process.env.EMAIL_USER!;
export const EMAIL_PASS = process.env.EMAIL_PASS!;
export const BASE_URL = process.env.BASE_URL ?? "http://localhost:3000";

export const TWILIO_SID = process.env.TWILIO_SID!;
export const TWILIO_AUTH = process.env.TWILIO_AUTH!;
export const TWILIO_VERIFY_SERVICE = process.env.TWILIO_VERIFY_SERVICE!;

export const MOCK_EMAIL = process.env.MOCK_EMAIL === "true";
export const MOCK_TWILIO_SMS = process.env.MOCK_TWILIO_SMS === "true";