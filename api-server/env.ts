import "dotenv/config";

export const PORT = process.env.PORT ? +process.env.PORT : undefined;

const jwtSecret = process.env.JWT_SECRET;
if (!jwtSecret) {
  throw new Error("JWT_SECRET environment variable not set");
}
export const JWT_SECRET = jwtSecret;

const databaseURL = process.env.DATABASE_URL;
if (!databaseURL) {
  throw new Error("DATABASE_URL environment variable not set");
}
export const DATABASE_URL = databaseURL;
