import { pgTable, serial, integer, text, timestamp, numeric, primaryKey, boolean } from "drizzle-orm/pg-core";

/**
 * Users table stores both customer accounts and internal bank accounts.
 *
 * Internal accounts (isInternal=true) represent bank entities like the cash
 * vault (physical cash holdings) and shareholder equity (owner's investment).
 *
 * Customer accounts (isInternal=false) represent liabilities to customers.
 */
export const users = pgTable("users", {
  userId: serial("user_id").primaryKey(),
  fullName: text("full_name").notNull(),
  phoneNumber: text("phone_number").notNull(),
  email: text("email").notNull().unique(),
  hashedPin: text("hashed_pin").notNull(),
  isInternal: boolean("is_internal").notNull().default(false),
});

/**
 * Transactions table groups related ledger entries together.
 *
 * Each transaction represents a complete financial event (e.g., withdrawal,
 * deposit, transfer) and contains multiple ledger entries that must balance
 * according to double-entry accounting (assets + liabilities = 0).
 */
export const transactions = pgTable("transactions", {
  transactionId: serial("transaction_id").primaryKey(),
  description: text("description"),
  timestamp: timestamp("timestamp").defaultNow().notNull(),
});

/**
 * Ledger table stores individual accounting entries using an asset/liability
 * perspective. Positive `change` indicates increase in assets OR decrease in
 * liabilities. Negative `change` indicates decrease in assets OR increase in
 * liabilities. Every `change` must sum to 0.
 *
 * Examples:
 * - Customer deposit: Customer account -$100 (liability ↑), Cash vault +$100 (asset ↑)
 * - Customer withdrawal: Customer account +$100 (liability ↓), Cash vault -$100 (asset ↓)
 */
export const ledger = pgTable("ledger", {
  entryId: serial("entry_id").primaryKey(),
  transactionId: integer("transaction_id")
    .notNull()
    .references(() => transactions.transactionId, {
      onUpdate: "cascade",
      onDelete: "cascade",
    }),
  userId: integer("user_id")
    .notNull()
    .references(() => users.userId, {
      onUpdate: "cascade",
      onDelete: "cascade",
    }),
  change: numeric("change", { precision: 10, scale: 2 }).notNull(),
});

/**
 * ATMs table stores physical ATM locations.
 */
export const atms = pgTable("atms", {
  atmId: serial("atm_id").primaryKey(),
  location: text("location").notNull(),
});

/**
 * Touchless sessions table tracks active ATM sessions. Each ATM can only be
 * engaged in one session at a time, and each user can only have one active
 * ATM session at a time.
 */
export const touchlessSessions = pgTable(
  "touchless_sessions",
  {
    userId: integer("user_id")
      .unique()
      .references(() => users.userId, {
        onUpdate: "cascade",
        onDelete: "cascade",
      }),
    atmId: integer("atm_id")
      .unique()
      .references(() => atms.atmId, {
        onUpdate: "cascade",
        onDelete: "cascade",
      }),
    startedAt: timestamp("started_at").defaultNow().notNull(),
  },
  (table) => [primaryKey({ columns: [table.userId, table.atmId] })],
);

// refresh tokens table
export const refreshTokens = pgTable("refresh_tokens", {
  token: text("token").primaryKey(),
  userId: integer("user_id")
    .unique()
    .references(() => users.userId, { onDelete: "cascade" }), // deletes token if user is deleted
  expiresAt: timestamp("expires_at").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});
