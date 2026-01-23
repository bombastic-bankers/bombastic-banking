import { and, eq, gt } from "drizzle-orm";
import { db } from "../index.js";
import { refreshTokens } from "../schema.js";

/**
 * Sets a refresh token for a user.
 */
export async function setRefreshToken(userId: number, token: string, expiresAt: Date) {
  await db
    .insert(refreshTokens)
    .values({ userId, token, expiresAt })
    .onConflictDoUpdate({ target: refreshTokens.userId, set: { token, expiresAt } });
}

/**
 * Updates (resets) a refresh token with a new token and expiration date.
 * Returns the userId if the old token exists and is not expired, `null` otherwise.
 */
export async function resetRefreshToken(
  oldToken: string,
  newToken: string,
  newExpiresAt: Date,
): Promise<number | null> {
  const results = await db
    .update(refreshTokens)
    .set({ token: newToken, expiresAt: newExpiresAt })
    .where(and(eq(refreshTokens.token, oldToken), gt(refreshTokens.expiresAt, new Date())))
    .returning({ userId: refreshTokens.userId });

  return results[0]?.userId ?? null;
}
