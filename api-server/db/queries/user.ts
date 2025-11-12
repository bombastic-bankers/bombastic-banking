import { db } from "..";
import { users } from "../schema";
import { eq } from "drizzle-orm";

export async function createUser(
  user: typeof users.$inferInsert,
): Promise<typeof users.$inferSelect> {
  return (await db.insert(users).values(user).returning())[0];
}

export async function getUserByEmail(
  email: string,
): Promise<typeof users.$inferSelect | null> {
  return (
    (await db.select().from(users).where(eq(users.email, email))).at(0) ?? null
  );
}
