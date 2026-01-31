import { and, eq, gt, isNull, or } from "drizzle-orm";
import { db } from "../index.js";
import { refreshTokens, users } from "../schema.js";

/**
 * Sets a refresh token for a user.
 */
export async function setRefreshToken(userId: number, token: string, expiresAt: Date | null) {
  await db
    .insert(refreshTokens)
    .values({ userId, token, expiresAt })
    .onConflictDoUpdate({ target: refreshTokens.userId, set: { token, expiresAt } });
}

/**
 * Updates (resets) a refresh token with a new token and expiration date.
 * Returns the user if the old token exists and is not expired, `null` otherwise.
 */
export async function resetRefreshToken(
  oldToken: string,
  newToken: string,
  newExpiresAt: Date | null,
): Promise<typeof users.$inferSelect | null> {
  const results = await db
    .update(refreshTokens)
    .set({ token: newToken, expiresAt: newExpiresAt })
    .from(users)
    .where(
      and(
        eq(refreshTokens.userId, users.userId),
        eq(refreshTokens.token, oldToken),
        or(isNull(refreshTokens.expiresAt), gt(refreshTokens.expiresAt, new Date())),
      ),
    )
    .returning({
      userId: users.userId,
      fullName: users.fullName,
      phoneNumber: users.phoneNumber,
      email: users.email,
      hashedPin: users.hashedPin,
      phoneVerified: users.phoneVerified,
      emailVerified: users.emailVerified,
      isInternal: users.isInternal,
    });

  return results[0] ?? null;
}
