import { db } from "../index.js";
import { ledger, users } from "../schema.js";
import { eq, sql } from "drizzle-orm";
import bcrypt from "bcryptjs";
import { EmailAlreadyExistsError, PhoneNumberAlreadyExistsError } from "./errors.js";

/**
 * Create a new user account.
 * @throws {EmailAlreadyExistsError} If the email is already in use.
 * @throws {PhoneNumberAlreadyExistsError} If the phone number is already in use.
 */
export async function createUser(user: {
  fullName: string;
  phoneNumber: string;
  email: string;
  pin: string;
}): Promise<number> {
  const hashedPin = await bcrypt.hash(user.pin, 10);

  return await db.transaction(async (tx) => {
    const existingEmail = await tx.select().from(users).where(eq(users.email, user.email));
    if (existingEmail.length > 0) {
      throw new EmailAlreadyExistsError(user.email);
    }

    const existingPhone = await tx.select().from(users).where(eq(users.phoneNumber, user.phoneNumber));
    if (existingPhone.length > 0) {
      throw new PhoneNumberAlreadyExistsError(user.phoneNumber);
    }

    const [{ userId }] = await tx
      .insert(users)
      .values({
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        email: user.email,
        hashedPin: hashedPin,
      })
      .returning({ userId: users.userId });

    return userId;
  });
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
 * Retrieve a user by their ID.
 */
export async function getUserById(userId: number): Promise<typeof users.$inferSelect | null> {
  const results = await db.select().from(users).where(eq(users.userId, userId));
  return results.at(0) ?? null;
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
export async function getUserAccOverview(userId: number): Promise<{ fullName: string; accountBalance: number }> {
  const { fullName } = (await db.select({ fullName: users.fullName }).from(users).where(eq(users.userId, userId)))[0];
  const { accountBalance: accountBalanceString } = (
    await db
      .select({ accountBalance: sql`-sum(${ledger.change})` })
      .from(ledger)
      .where(eq(ledger.userId, userId))
  )[0];

  return { fullName, accountBalance: +(accountBalanceString ?? 0) };
}

/**
 * Updates the user profile with the provided fields.
 */
export async function updateUserProfile(
  userId: number,
  patch: {
    fullName?: string;
    phoneNumber?: string;
    email?: string;
  },
): Promise<{
  userId: number;
  fullName: string;
  phoneNumber: string;
  email: string;
} | null> {
  const updatedRows = await db
    .update(users)
    .set({
      ...(patch.fullName !== undefined ? { fullName: patch.fullName } : {}),
      ...(patch.phoneNumber !== undefined ? { phoneNumber: patch.phoneNumber } : {}),
      ...(patch.email !== undefined ? { email: patch.email } : {}),
    })
    .where(eq(users.userId, userId))
    .returning({
      userId: users.userId,
      fullName: users.fullName,
      phoneNumber: users.phoneNumber,
      email: users.email,
    });

  return updatedRows[0] ?? null;
}

/**
 * Retrieves a user's profile information by their unique ID.
 */
export async function getUserProfile(userId: number): Promise<{
  fullName: string;
  phoneNumber: string;
  email: string;
} | null> {
  const rows = await db
    .select({
      fullName: users.fullName,
      phoneNumber: users.phoneNumber,
      email: users.email,
    })
    .from(users)
    .where(eq(users.userId, userId));
  return rows[0] ?? null;
}
