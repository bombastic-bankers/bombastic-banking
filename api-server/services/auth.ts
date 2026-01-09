import jwt from "jsonwebtoken";
import crypto from "crypto";
import { JWT_SECRET } from "../env";

/**
 * Generate a new access and refresh token for the specified user.
 */
export async function generateAuthTokens(userId: number) {
  const accessToken = jwt.sign({ userId }, JWT_SECRET, { expiresIn: "2m" });

  const refreshToken = crypto.randomBytes(40).toString("hex");
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);

  return { accessToken, refreshToken };
}
