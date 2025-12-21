import { pgTable, serial, integer, text, timestamp, numeric, primaryKey, boolean, varchar } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  userId: serial("user_id").primaryKey(),
  fullName: text("full_name").notNull(),
  phoneNumber: text("phone_number").notNull(),
  email: text("email").notNull().unique(),
  hashedPin: text("hashed_pin").notNull(),
  phoneverified: boolean("phoneverified").default(false),
  emailverified: boolean("emailverified").default(false),
  emailToken: varchar("emailtoken", { length: 255 }),      
  emailTokenExpiry: timestamp("emailtokenexpiry"),    

});

export const ledger = pgTable("transaction_ledger", {
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

export const atms = pgTable("atms", {
  atmId: serial("atm_id").primaryKey(),
  location: text("location").notNull(),
});

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
  (table) => [primaryKey({ columns: [table.userId, table.atmId] })]
);
