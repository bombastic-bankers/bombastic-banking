import { drizzle } from "drizzle-orm/neon-serverless";
import env from "../env.js";

let _db: ReturnType<typeof drizzle> | null = null;

/**
 * Lazily-initialized database connection.
 */
export const db = new Proxy({} as ReturnType<typeof drizzle>, {
  get(_, prop) {
    if (!_db) _db = drizzle(env.DATABASE_URL);
    return Reflect.get(_db, prop);
  },
});
