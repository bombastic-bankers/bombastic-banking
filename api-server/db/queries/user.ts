import { db } from "../index.js";
import { ledger, users } from "../schema.js";
import { eq, sum } from "drizzle-orm";

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

export async function getUserInfo(
  userId: number,
): Promise<{ fullName: string; accountBalance: number }> {
  const { fullName } = (
    await db
      .select({ fullName: users.fullName })
      .from(users)
      .where(eq(users.userId, userId))
  )[0];
  const { accountBalance: accountBalanceString } = (
    await db
      .select({ accountBalance: sum(ledger.amount) })
      .from(ledger)
      .where(eq(ledger.userId, userId))
  )[0];

  return { fullName, accountBalance: +(accountBalanceString ?? 0) };
}
