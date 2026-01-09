import { and, eq } from "drizzle-orm";
import { db } from "../index.js";
import { touchlessSessions, ledger, atms, transactions } from "../schema.js";
import { CASH_VAULT_USER_ID } from "../constants.js";

/**
 * Check if an ATM with the specified ID exists.
 */
export async function atmExists(atmId: number): Promise<boolean> {
  const result = await db.select().from(atms).where(eq(atms.atmId, atmId));
  return result.length > 0;
}

/**
 * Initiate a touchless ATM session, returning `false` if the ATM is already in
 * use by another user or if the userId or atmId doesn't exist. No-op if the
 * user already has a session with that ATM.
 */
export async function ensureTouchlessSession(userId: number, atmId: number): Promise<boolean> {
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
    return false;
  }

  if (result.length > 0) {
    return true;
  }

  // Check if session already exists for this user-ATM pair
  const existing = await db
    .select()
    .from(touchlessSessions)
    .where(and(eq(touchlessSessions.userId, userId), eq(touchlessSessions.atmId, atmId)))
    .limit(1);

  return existing.length > 0;
}

/**
 * End a touchless ATM session.
 */
export async function endTouchlessSession(userId: number, atmId: number): Promise<boolean> {
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
    const [withdrawalTransaction] = await tx
      .insert(transactions)
      .values({
        description: "Cash withdrawal",
      })
      .returning();

    await tx.insert(ledger).values([
      {
        transactionId: withdrawalTransaction.transactionId,
        userId: userId,
        change: amount.toFixed(2),
      },
      {
        transactionId: withdrawalTransaction.transactionId,
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
    const [transaction] = await tx
      .insert(transactions)
      .values({
        description: "Cash deposit",
      })
      .returning();

    await tx.insert(ledger).values([
      {
        transactionId: transaction.transactionId,
        userId: userId,
        change: (-amount).toFixed(2),
      },
      {
        transactionId: transaction.transactionId,
        userId: CASH_VAULT_USER_ID,
        change: amount.toFixed(2),
      },
    ]);
  });
}
