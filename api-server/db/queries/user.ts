import { db } from "../index.js";
import {
  ledger,
  users,
  emailVerificationCodes,
  smsVerificationCodes,
} from "../schema.js";
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
export async function getUserByCredentials(
  email: string,
  pin: string
): Promise<typeof users.$inferSelect | null> {
  const result = await db
    .select()
    .from(users)
    .where(eq(users.email, email))
    .limit(1);
  if (result.length === 0) return null;
  if (!(await bcrypt.compare(pin, result[0].hashedPin))) return null;
  return result[0];
}

export async function getUserInfo(
  userId: number
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
// Get user by phone number
export async function getUserByPhoneNumber(
  phoneNumber: string
): Promise<typeof users.$inferSelect | null> {
  const result = await db
    .select()
    .from(users)
    .where(eq(users.phoneNumber, phoneNumber))
    .limit(1);
  return result[0] ?? null;
}
export async function getUserByEmail(
  email: string
): Promise<typeof users.$inferSelect | null> {
  const result = await db
    .select()
    .from(users)
    .where(eq(users.email, email))
    .limit(1);
  return result[0] ?? null;
}

export async function saveEmailToken(
  email: string,
  token: string,
  expiresAt: Date
): Promise<void> {
  await db
    .delete(emailVerificationCodes)
    .where(eq(emailVerificationCodes.email, email));
  await db.insert(emailVerificationCodes).values({
    email,
    token,
    expiresAt,
  });
}
export async function getEmailVerificationByToken(
  token: string
): Promise<typeof emailVerificationCodes.$inferSelect | null> {
  const result = await db
    .select()
    .from(emailVerificationCodes)
    .where(eq(emailVerificationCodes.token, token))
    .limit(1);
  return result[0];
}
export async function deleteEmailToken(id: number): Promise<void> {
  await db
    .delete(emailVerificationCodes)
    .where(eq(emailVerificationCodes.id, id));
}

export async function getEmailVerificationByEmail(email: string) {
  const result = await db
    .select()
    .from(emailVerificationCodes)
    .where(eq(emailVerificationCodes.email, email))
    .limit(1);

  return result[0] ?? null;
}
export async function getPhoneVerificationByPhoneNumber(phoneNumber: string) {
  const result = await db
    .select()
    .from(smsVerificationCodes)
    .where(eq(smsVerificationCodes.phoneNumber, phoneNumber))
    .limit(1);
  return result[0];
}
export async function savePhoneVerificationSuccess(phoneNumber: string) {
  return await db
    .insert(smsVerificationCodes)
    .values({ phoneNumber, verifiedAt: new Date() })
    .onConflictDoUpdate({
      target: smsVerificationCodes.phoneNumber,
      set: { verifiedAt: new Date() },
    });
}
