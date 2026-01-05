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
}): Promise<boolean> {
  const inserted = await db
    .insert(users)
    .values({
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      email: user.email,
      hashedPin: await bcrypt.hash(user.pin, 10),
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

/**
 * update the user profile with the related information.
 */
export type UpdateUserProfilePatch = {
  fullName?: string;
  phoneNumber?: string;
  email?: string;
};

export async function updateUserProfile(
  userId: number,
  patch: UpdateUserProfilePatch
): Promise<{ userId: number; fullName: string; phoneNumber: string; email: string } | null> {
  const updatedRows = await db
    .update(users)
    .set({
      ...(patch.fullName !== undefined ? { fullName: patch.fullName } : {}),
      ...(patch.phoneNumber !== undefined ? { phoneNumber: patch.phoneNumber } : {}),
      ...(patch.email !== undefined ? { email: patch.email } : {})
    })
    .where(eq(users.userId, userId))
    .returning({
      userId: users.userId,
      fullName: users.fullName,
      phoneNumber: users.phoneNumber,
      email: users.email
    });

  return updatedRows[0] ?? null;
}
