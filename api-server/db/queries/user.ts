import { db } from "../index.js";
import { ledger, users } from "../schema.js";
import { eq, sum, and } from "drizzle-orm";
import bcrypt from "bcryptjs";

/**
 * Attempt to create a new user, returning `false` if
 * the email is already in use and `true` otherwise.
 */
export async function createUser(user: {
  fullName: string;
  phoneNumber: string;
  email: string;
  pin: string;
  emailToken?: string;        
  emailTokenExpiry?: Date;
}): Promise<boolean> {
  const inserted = await db
    .insert(users)
    .values({
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      email: user.email,
      hashedPin: await bcrypt.hash(user.pin, 10),
      emailToken: user.emailToken,
      emailTokenExpiry: user.emailTokenExpiry,
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

export async function getUserInfo(userId: number): Promise<{ fullName: string; accountBalance: number }> {
  const { fullName } = (await db.select({ fullName: users.fullName }).from(users).where(eq(users.userId, userId)))[0];
  const { accountBalance: accountBalanceString } = (
    await db
      .select({ accountBalance: sum(ledger.amount) })
      .from(ledger)
      .where(eq(ledger.userId, userId))
  )[0];

  return { fullName, accountBalance: +(accountBalanceString ?? 0) };
}
// Get user by phone number
export async function getUserByPhoneNumber(phoneNumber: string): Promise<typeof users.$inferSelect | null> {
  const result = await db.select().from(users).where(eq(users.phoneNumber, phoneNumber)).limit(1);
  return result[0] ?? null;
}

// Update phoneVerified flag
export async function updatePhoneVerified(userId: number, verified: boolean): Promise<void> {
  await db.update(users).set({ phoneverified: verified }).where(eq(users.userId, userId));
}
export async function getUserByEmail(email: string) {
  const result = await db
    .select()
    .from(users)
    .where(eq(users.email, email))
    .limit(1);

  return result[0] ?? null;
}
export async function getUserByEmailToken(token: string): Promise<typeof users.$inferSelect | null> {
  const result = await db.select().from(users).where(eq(users.emailToken, token)).limit(1);
  return result[0] ?? null;
}

export async function verifyUserEmail(userId: number) {
  await db.update(users)
    .set({ 
      emailverified: true, 
      emailToken: null, 
      emailTokenExpiry: null 
    })
    .where(eq(users.userId, userId));
}