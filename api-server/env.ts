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
  get EMAIL_USER(): string {
    return getEnvOrThrow("EMAIL_USER");
  },
  get EMAIL_PASS(): string {
    return getEnvOrThrow("EMAIL_PASS");
  },
  get BASE_URL(): string {
    return process.env.BASE_URL ?? "http://localhost:3000";
  },
  set BASE_URL(value: string) {
    process.env.BASE_URL = value;
  },
  get TWILIO_SID(): string {
    return getEnvOrThrow("TWILIO_SID");
  },
  get TWILIO_AUTH(): string {
    return getEnvOrThrow("TWILIO_AUTH");
  },
  get TWILIO_VERIFY_SERVICE(): string {
    return getEnvOrThrow("TWILIO_VERIFY_SERVICE");
  },
};

export default env;
