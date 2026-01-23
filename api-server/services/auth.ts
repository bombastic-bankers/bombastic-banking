import jwt from "jsonwebtoken";
import crypto from "crypto";
import env from "../env.js";

export function generateAccessToken(userId: number): string {
  return jwt.sign({ userId }, env.JWT_SECRET, { expiresIn: "2m" });
}

export function generateRefreshToken(): string {
  return crypto.randomBytes(40).toString("base64url");
}
