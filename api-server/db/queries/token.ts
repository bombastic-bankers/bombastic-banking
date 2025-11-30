import { eq } from "drizzle-orm";
import { db } from ".."; // imports from db/index.ts
import { refreshTokens } from "../schema";

// used by tokenService.ts
export async function createRefreshToken(data: {
  userId: number;
  token: string;
  expiresAt: Date;
}) {
  await db.insert(refreshTokens).values(data);
}

// used by users.ts - api-server/controllers/users.ts
export async function getRefreshToken(token: string) {
  const [storedToken] = await db
    .select()
    .from(refreshTokens)
    .where(eq(refreshTokens.token, token))
    .limit(1);

  return storedToken;
}

// used by users.ts - api-server/controllers/users.ts
export async function deleteRefreshToken(id: number) {
  await db.delete(refreshTokens).where(eq(refreshTokens.id, id));
}
