import { and, eq } from "drizzle-orm";
import { db } from "../index.js";
import { touchlessSessions, ledger, atms } from "../schema.js";

/**
 * Return whether an ATM with the specified ID exists.
 */
export async function atmExists(atmId: number): Promise<boolean> {
  const result = await db.select().from(atms).where(eq(atms.atmId, atmId));
  return result.length > 0;
}

/**
 * Initiate a touchless ATM session, returning `false`
 * if the ATM is already in use and `true` otherwise.
 */
export async function startTouchlessSession(
  userId: number,
  atmId: number,
): Promise<boolean> {
  const result = await db
    .insert(touchlessSessions)
    .values({ userId, atmId })
    .onConflictDoNothing()
    .returning();
  return result.length > 0;
}

/**
 * End a touchless ATM session, returning `false`
 * if the session does not exist and `true` otherwise.
 */
export async function endTouchlessSession(
  userId: number,
  atmId: number,
): Promise<boolean> {
  const result = await db
    .delete(touchlessSessions)
    .where(
      and(
        eq(touchlessSessions.userId, userId),
        eq(touchlessSessions.atmId, atmId),
      ),
    )
    .returning();
  return result.length > 0;
}

/**
 * Return `true` if the specified touchless session exists.
 */
export async function touchlessSessionExists(
  userId: number,
  atmId: number,
): Promise<boolean> {
  const result = await db
    .select()
    .from(touchlessSessions)
    .where(
      and(
        eq(touchlessSessions.userId, userId),
        eq(touchlessSessions.atmId, atmId),
      ),
    );

  return result.length > 0;
}

/**
 * Update the ledger to reflect a cash withdrawal.
 */
export async function updateLedgerForWithdrawal(
  userId: number,
  amount: number,
) {
  await db.insert(ledger).values({ userId, amount: (-amount).toFixed(2) });
}

/**
 * Update the ledger to reflect a cash deposit.
 */
export async function depositCash(userId: number, amount: number) {
  await db.insert(ledger).values({ userId, amount: amount.toFixed(2) });
}
