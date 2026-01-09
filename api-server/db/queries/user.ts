import { db } from "../index.js";
import { ledger, users } from "../schema.js";
import { eq, sum, and } from "drizzle-orm";
import bcrypt from "bcryptjs";

/**
 * Create a new user account. Returns whether the account already exists.
 */
export async function createUser(user: {
  fullName: string;
  phoneNumber: string;
  email: string;
  pin: string;
}): Promise<boolean> {
  const hashedPin = await bcrypt.hash(user.pin, 10);
  const inserted = await db
    .insert(users)
    .values({
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      email: user.email,
      hashedPin: hashedPin,
      isInternal: false,
    })
    .onConflictDoNothing()
    .returning();
  return inserted.length > 0;
}

/**
 * Return the user with the given email and PIN, or `null` if no such user exists.
 */
export async function getUserByCredentials(email: string, pin: string): Promise<typeof users.$inferSelect | null> {
  const result = await db.select().from(users).where(eq(users.email, email)).limit(1);
  if (result.length === 0) return null;
  if (!(await bcrypt.compare(pin, result[0].hashedPin))) return null;
  return result[0];
}

/**
 * Retrieve a user by their email address.
 */
export async function getUserByEmail(email: string): Promise<typeof users.$inferSelect | null> {
  const results = await db.select().from(users).where(eq(users.email, email));
  return results.at(0) ?? null;
}

/**
 * Retrieve a user by their phone number.
 */
export async function getUserByPhoneNumber(phoneNumber: string): Promise<typeof users.$inferSelect | null> {
  const results = await db.select().from(users).where(eq(users.phoneNumber, phoneNumber));
  return results.at(0) ?? null;
}

/**
 * Get user information including their current account balance.
 */
export async function getUserInfo(userId: number): Promise<{ fullName: string; accountBalance: number }> {
  const { fullName } = (await db.select({ fullName: users.fullName }).from(users).where(eq(users.userId, userId)))[0];
  const { accountBalance: accountBalanceString } = (
    await db
      .select({ accountBalance: sum(ledger.change) })
      .from(ledger)
      .where(eq(ledger.userId, userId))
  )[0];

  return { fullName, accountBalance: +(accountBalanceString ?? 0) };
}
