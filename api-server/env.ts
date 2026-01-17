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
  get NGROK_AUTHTOKEN(): string | undefined {
    return process.env.NGROK_AUTHTOKEN;
  },
};

export default env;

export const EMAIL_USER = process.env.EMAIL_USER!;
export const EMAIL_PASS = process.env.EMAIL_PASS!;
export const BASE_URL = process.env.BASE_URL ?? "http://localhost:3000";

export const TWILIO_SID = process.env.TWILIO_SID!;
export const TWILIO_AUTH = process.env.TWILIO_AUTH!;
export const TWILIO_VERIFY_SERVICE = process.env.TWILIO_VERIFY_SERVICE!;

export const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY!;
export const SENDGRID_VERIFIED_EMAIL = process.env.SENDGRID_VERIFIED_EMAIL!;
export const NGROK_AUTHTOKEN = process.env.NGROK_AUTHTOKEN!;