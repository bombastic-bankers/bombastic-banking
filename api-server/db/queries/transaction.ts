import { db } from "../index.js";
import { ledger, transactions, users } from "../schema.js";
import { eq, sql, sum } from "drizzle-orm";

/**
 * Transfer money from one user to another. Returns false
 * if the transfer fails due to insufficient funds.
 */
export async function transferMoney(
  fromUserId: number,
  toUserId: number,
  amount: number,
  description?: string,
): Promise<boolean> {
  try {
    await db.transaction(async (tx) => {
      const [{ balance }] = await tx
        .select({ balance: sql<number>`-sum(${ledger.change})` })
        .from(ledger)
        .where(eq(ledger.userId, fromUserId));
      if (balance < amount) {
        tx.rollback();
      }

      const [{ transactionId }] = await tx
        .insert(transactions)
        .values({
          description: description ?? "Transfer",
        })
        .returning();

      await tx.insert(ledger).values([
        {
          transactionId,
          userId: fromUserId,
          change: amount.toFixed(2),
        },
        {
          transactionId,
          userId: toUserId,
          change: (-amount).toFixed(2),
        },
      ]);
    });
  } catch (error) {
    return false;
  }

  return true;
}
