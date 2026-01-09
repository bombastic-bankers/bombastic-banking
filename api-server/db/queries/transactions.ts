import { db } from "../index.js";
import { ledger, transactions } from "../schema.js";

/**
 * Transfer money from one user to another.
 */
export async function transferMoney(
  fromUserId: number,
  toUserId: number,
  amount: number,
  description?: string,
): Promise<void> {
  await db.transaction(async (tx) => {
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
}
