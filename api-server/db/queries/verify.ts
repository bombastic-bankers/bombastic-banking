import { db } from "../index.js";
import { users, emailVerifications } from "../schema.js";
import { eq } from "drizzle-orm";

/**
 * Update phoneVerified flag.
 */
export async function updatePhoneVerified(userId: number, verified: boolean): Promise<void> {
  await db.update(users).set({ phoneVerified: verified }).where(eq(users.userId, userId));
}

/**
 * Verify user's email by token and delete verification token atomically.
 * Returns the verified user object with emailTokenExpiry.
 */
export async function verifyUserEmailByToken(
  token: string,
): Promise<(typeof users.$inferSelect & { emailTokenExpiry: Date }) | null> {
  return await db.transaction(async (tx) => {
    const results = await tx
      .select({
        userId: users.userId,
        fullName: users.fullName,
        phoneNumber: users.phoneNumber,
        email: users.email,
        hashedPin: users.hashedPin,
        phoneVerified: users.phoneVerified,
        emailVerified: users.emailVerified,
        isInternal: users.isInternal,
        emailTokenExpiry: emailVerifications.expiresAt,
      })
      .from(emailVerifications)
      .innerJoin(users, eq(emailVerifications.userId, users.userId))
      .where(eq(emailVerifications.token, token));

    const user = results.at(0);
    if (!user) return null;

    await tx.update(users).set({ emailVerified: true }).where(eq(users.userId, user.userId));
    await tx.delete(emailVerifications).where(eq(emailVerifications.userId, user.userId));

    return {
      userId: user.userId,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      email: user.email,
      hashedPin: user.hashedPin,
      phoneVerified: user.phoneVerified,
      emailVerified: true,
      isInternal: user.isInternal,
      emailTokenExpiry: user.emailTokenExpiry,
    };
  });
}

/**
 * Save or update email verification token for a user.
 */
export async function saveEmailToken(userId: number, token: string, expiry: Date): Promise<void> {
  await db
    .insert(emailVerifications)
    .values({
      userId,
      token,
      expiresAt: expiry,
    })
    .onConflictDoUpdate({
      target: emailVerifications.userId,
      set: {
        token,
        expiresAt: expiry,
      },
    });
}
