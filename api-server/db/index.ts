import { drizzle } from "drizzle-orm/neon-http";
import { DATABASE_URL } from "../env.js";

export const db = drizzle(DATABASE_URL);
