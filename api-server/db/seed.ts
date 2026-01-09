/**
 * Seed the database with sample data, removing all existing data.
 */

import bcrypt from "bcryptjs";
import { db } from "./index.js";
import { atms, ledger, users, transactions } from "./schema.js";
import * as schema from "./schema.js";
import { CASH_VAULT_USER_ID, SHAREHOLDER_EQUITY_USER_ID } from "./constants.js";
import { reset } from "drizzle-seed";

await reset(db, schema);

// Create internal accounts
await db.insert(users).values([
  {
    userId: CASH_VAULT_USER_ID,
    fullName: "Cash Vault",
    phoneNumber: "00000000",
    email: "cash-vault@internal.bombastic-banking",
    hashedPin: await bcrypt.hash("internal", 10),
    isInternal: true,
  },
  {
    userId: SHAREHOLDER_EQUITY_USER_ID,
    fullName: "Shareholder Equity",
    phoneNumber: "00000000",
    email: "shareholder-equity@internal.bombastic-banking",
    hashedPin: await bcrypt.hash("internal", 10),
    isInternal: true,
  },
]);

// Initial transaction for bank capitalization
const [initialTransaction] = await db
  .insert(transactions)
  .values({
    description: "Initial bank capitalization",
  })
  .returning();

// Create balanced ledger entries
await db.insert(ledger).values([
  {
    transactionId: initialTransaction.transactionId,
    userId: CASH_VAULT_USER_ID,
    change: "10000.00", // Asset increase (positive)
  },
  {
    transactionId: initialTransaction.transactionId,
    userId: SHAREHOLDER_EQUITY_USER_ID,
    change: "-10000.00", // Equity (negative, balances the asset)
  },
]);

// Create ATM
await db.insert(atms).values({ atmId: 1, location: "OCBC Centre Branch" });
