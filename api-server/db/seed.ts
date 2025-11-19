/** Seed the database with sample data, removing all existing data. */

import bcrypt from "bcryptjs";
import { db } from "./index.js";
import { atms, touchlessSessions, ledger, users } from "./schema.js";

await db.delete(users);
await db.insert(users).values({
  userId: 1,
  fullName: "Jayden Tan",
  phoneNumber: "91234567",
  email: "jaydentan@gmail.com",
  hashedPassword: await bcrypt.hash("password123", 10),
});

await db.delete(ledger);
await db.insert(ledger).values({
  userId: 1,
  amount: "100.00",
  timestamp: new Date(2025, 10, 19, 14, 30),
});

await db.delete(atms);
await db.insert(atms).values({ atmId: 1, location: "OCBC Centre Branch" });

await db.delete(touchlessSessions);
