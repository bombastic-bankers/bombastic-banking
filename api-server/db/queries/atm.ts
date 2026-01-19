import { and, eq } from "drizzle-orm";
import { db } from "../index.js";
import { touchlessSessions, ledger, transactions } from "../schema.js";
import { CASH_VAULT_USER_ID } from "../constants.js";

/**
 * Initiate a touchless ATM session, returning `null` if the ATM is already in
 * use by another user or if the userId or atmId doesn't exist. No-op if the
 * user already has a session with that ATM.
 */
export async function ensureATMSession(
  userId: number,
  atmId: number,
): Promise<{ depositAmount: number | null } | null> {
  let result: (typeof touchlessSessions.$inferSelect)[];
  try {
    // If the insert fails because of a conflict (no error, result.length == 0),
    // it's because:
    // 1. The user already has a session with that ATM
    // 2. The user already has a session with another ATM
    // 3. The ATM is already in use by another user
    //
    // If the insert fails because of a foreign key constraint violation
    // (error), it's because the userId or atmId doesn't exist.
    result = await db.insert(touchlessSessions).values({ userId, atmId }).onConflictDoNothing().returning();
  } catch (error) {
    return null;
  }

  if (result.length > 0) {
    return { depositAmount: toOptionalNumber(result[0].depositAmount) };
  }

  // This will return no rows if the ATM is in use by another user
  const existing = await db
    .select()
    .from(touchlessSessions)
    .where(and(eq(touchlessSessions.userId, userId), eq(touchlessSessions.atmId, atmId)))
    .limit(1);

  return { depositAmount: toOptionalNumber(existing[0]?.depositAmount) };
}

function toOptionalNumber(value: string | null | undefined): number | null {
  return value === null || value === undefined ? null : +value;
}

/**
 * Save the deposit amount for an active ATM session.
 * Returns `false` if no such session exists.
 */
export async function setSessionDeposit(userId: number, atmId: number, amount: number): Promise<boolean> {
  const results = await db
    .update(touchlessSessions)
    .set({ depositAmount: amount.toFixed(2) })
    .where(and(eq(touchlessSessions.userId, userId), eq(touchlessSessions.atmId, atmId)))
    .returning();
  return results.length > 0;
}

/**
 * End a touchless ATM session.
 */
export async function endATMSession(userId: number, atmId: number): Promise<boolean> {
  const result = await db
    .delete(touchlessSessions)
    .where(and(eq(touchlessSessions.userId, userId), eq(touchlessSessions.atmId, atmId)))
    .returning();
  return result.length > 0;
}

/**
 * Process a cash withdrawal from an ATM.
 */
export async function withdrawCash(userId: number, amount: number): Promise<void> {
  await db.transaction(async (tx) => {
    const [{ transactionId }] = await tx
      .insert(transactions)
      .values({
        description: "Cash withdrawal",
      })
      .returning();

    await tx.insert(ledger).values([
      {
        transactionId,
        userId: userId,
        change: amount.toFixed(2),
      },
      {
        transactionId,
        userId: CASH_VAULT_USER_ID,
        change: (-amount).toFixed(2),
      },
    ]);
  });
}

/**
 * Process a cash deposit to an ATM.
 */
export async function depositCash(userId: number, amount: number): Promise<void> {
  await db.transaction(async (tx) => {
    const [{ transactionId }] = await tx
      .insert(transactions)
      .values({
        description: "Cash deposit",
      })
      .returning();

    await tx.insert(ledger).values([
      {
        transactionId,
        userId: userId,
        change: (-amount).toFixed(2),
      },
      {
        transactionId,
        userId: CASH_VAULT_USER_ID,
        change: amount.toFixed(2),
      },
    ]);
  });
}
