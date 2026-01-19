import { db } from "../index.js";
import { users } from "../schema.js";
import { eq, sum, and, inArray } from "drizzle-orm";

/** Retrieve the names and phone numbers of users based off of an array of phone numbers
 */
export async function getContactsByPhoneNumber(
  phoneNumbers: string[]
): Promise<{ fullName: string; phoneNumber: string }[]> {
  const contacts = await db
    .select({
      fullName: users.fullName,
      phoneNumber: users.phoneNumber,
    })
    .from(users)
    .where(inArray(users.phoneNumber, phoneNumbers));

  return contacts;
}
