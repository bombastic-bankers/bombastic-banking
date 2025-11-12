import {
  pgTable,
  serial,
  integer,
  text,
  timestamp,
  numeric,
} from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  userId: serial("user_id").primaryKey(),
  fullName: text("full_name").notNull(),
  phoneNumber: text("phone_number").notNull(),
  email: text("email").notNull().unique(),
  hashedPassword: text("hashed_password").notNull(),
});

export const transactionLedger = pgTable("transaction_ledger", {
  transactionId: serial("transaction_id").primaryKey(),
  userId: integer("user_id")
    .notNull()
    .references(() => users.userId, {
      onUpdate: "cascade",
      onDelete: "cascade",
    }),
  amount: numeric("amount", { precision: 10, scale: 2 }).notNull(),
  timestamp: timestamp("timestamp").defaultNow().notNull(),
});
