import jwt from "jsonwebtoken";
import crypto from "crypto";
import env from "../env.js";

/**
 * Generates an JWT for user authentication.
 *
 * - `verified` refers to whether the user's phone number and
 * email have been verified. If not set, this defaults to `false`.
 * - `expiresInSeconds` defaults to 120 (2 minutes). If set to `null`,
 * the token will never expire.
 */
export function generateAccessToken({
  userId,
  verified,
  expiresInSeconds,
}: {
  userId: number;
  verified?: boolean;
  expiresInSeconds?: number | null;
}): string {
  const options = expiresInSeconds === null ? {} : { expiresIn: expiresInSeconds ?? 120 };
  return jwt.sign(
    {
      iss: env.JWT_ISSUER,
      sub: `user|${userId}`,
      email_verified: verified ?? false,
      phone_verified: verified ?? false,
    },
    env.JWT_SECRET,
    options,
  );
}

export function generateRefreshToken(): string {
  return crypto.randomBytes(40).toString("base64url");
}
