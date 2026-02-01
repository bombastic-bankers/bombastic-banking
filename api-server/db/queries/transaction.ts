import { db } from "../index.js";
import { ledger, transactions, users } from "../schema.js";
import { eq, sql, sum, and, desc, ne } from "drizzle-orm";
import { alias } from "drizzle-orm/pg-core";

/**
 * Transfer money from one user to another. Returns the transaction ID if the
 * transfer is successful, or null if the transfer fails due to insufficient funds.
 */
export async function transferMoney(
  fromUserId: number,
  toUserId: number,
  amount: number,
  description?: string,
): Promise<number | null> {
  try {
    return await db.transaction(async (tx) => {
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
          type: "transfer",
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

      return transactionId;
    });
  } catch (error) {
    return null;
  }
}

/**
 * Retrieves the transaction history for a given user ID,
 * ordered by transaction timestamp in descending order.
 *
 * Each entry represents a transaction involving the user and may
 * include counterparty information derived from related ledger entries.
 *
 * Returns an empty array if the user has no transactions.
 */
export async function getTransactionHistory(userId: number): Promise<
  {
    transactionId: number;
    timestamp: Date;
    description: string | null;
    myChange: string;
    counterpartyUserId: number | null;
    counterpartyName: string | null;
    counterpartyIsInternal: boolean | null;
    type: string;
  }[]
> {
  const myLedger = alias(ledger, "myLedger");
  const otherLedger = alias(ledger, "otherLedger");
  const otherUser = alias(users, "otherUser");

  return db
    .select({
      transactionId: transactions.transactionId,
      timestamp: transactions.timestamp,
      description: transactions.description,
      myChange: sql<string>`sum(${myLedger.change})`.as("myChange"),
      counterpartyUserId: otherUser.userId,
      counterpartyName: otherUser.fullName,
      counterpartyIsInternal: otherUser.isInternal,
      type: transactions.type,
    })
    .from(myLedger)
    .innerJoin(transactions, eq(myLedger.transactionId, transactions.transactionId))
    .leftJoin(otherLedger, and(eq(otherLedger.transactionId, myLedger.transactionId), ne(otherLedger.userId, userId)))
    .leftJoin(otherUser, eq(otherUser.userId, otherLedger.userId))
    .where(eq(myLedger.userId, userId))
    .groupBy(
      transactions.transactionId,
      transactions.timestamp,
      transactions.description,
      otherUser.userId,
      otherUser.fullName,
      otherUser.isInternal,
    )
    .orderBy(desc(transactions.timestamp));
}
