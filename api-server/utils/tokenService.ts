import jwt from "jsonwebtoken";
import crypto from "crypto"; 
import { db } from "../db"; 
import { refreshTokens } from "../db/schema";
import { JWT_SECRET } from "../env"; 

export async function generateAuthTokens(userId: number) {
  const accessToken = jwt.sign({ userId }, JWT_SECRET, { expiresIn: "2m" });

  const refreshToken = crypto.randomBytes(40).toString("hex");

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);
  // valid for 30 days

  await db.insert(refreshTokens).values({
    userId: userId,
    token: refreshToken,
    expiresAt: expiresAt,
    // saves refresh token to db 
  });

  return { accessToken, refreshToken };
}