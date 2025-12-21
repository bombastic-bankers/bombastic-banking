import { Request, Response } from "express";
import z from "zod";
import * as queries from "../db/queries/index.js";
import { generateAccessToken, generateRefreshToken } from "../services/auth.js";
import { generateEmailToken, sendVerificationEmail } from "../services/emailVerificationService.js";
import { sendOTP } from "../services/smsVerificationService.js";

/** Create a new user account with the provided credentials. */
export async function signUp(req: Request, res: Response) {
  const userInit = z
    .object({
      fullName: z.string().min(1),
      phoneNumber: z.e164(),
      email: z.email(),
      pin: z.string().regex(/[0-9]{6}/),
    })
    .parse(req.body);

  // check if email or phone number already exists
  const existingUser = await queries.getUserByEmail(userInit.email);
  if (existingUser) {
    return res.status(409).json({ error: "Email already in use" });
  }

  const existingPhone = await queries.getUserByPhoneNumber(userInit.phoneNumber);
  if (existingPhone) {
    return res.status(409).json({ error: "This phone number is already in use." });
  }

  // create user
  const created = await queries.createUser({
    fullName: userInit.fullName,
    phoneNumber: userInit.phoneNumber,
    email: userInit.email,
    pin: userInit.pin,
  });

  if (!created) {
    return res.status(500).json({ error: "Failed to create account" });
  }
  const user = await queries.getUserByEmail(userInit.email);
  if (!user) {
    return res.status(500).json({ error: "Failed to retrieve new account" });
  }
  const { token, expiry } = generateEmailToken();
  await queries.saveEmailToken(user.userId, token, expiry);

  try {
    await sendVerificationEmail(userInit.email, token);
    await sendOTP(userInit.phoneNumber);

    return res.status(201).json({
      message: "Registration successful! Please verify your email and phone number.",
    });
  } catch (error) {
    console.error("AUTO_SEND_ERROR:", error);
    return res.status(201).json({
      message: "Account created, but verification codes failed to send. Please request a resend.",
    });
  }
}

/** Authenticate a user and issue access and refresh tokens. */

export async function login(req: Request, res: Response) {
  const { email, pin } = z
    .object({
      email: z.email(),
      pin: z.string().regex(/[0-9]{6}/),
    })
    .parse(req.body);
  const user = await queries.getUserByCredentials(email, pin);
  if (user === null) {
    return res.status(401).json({ error: "Incorrect email or PIN" });
  }
  if (!user.emailVerified || !user.phoneVerified) {
    return res.status(403).json({
      error: "Account not fully verified",
      message: "Please ensure both your email and phone number are verified.",
    });
  }
  const accessToken = generateAccessToken(user.userId);
  const refreshToken = generateRefreshToken();
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);
  await queries.setRefreshToken(user.userId, refreshToken, expiresAt);

  res.json({ accessToken, refreshToken });
}

/** Return the authenticated user's information. */
export async function getUserAccOverview(req: Request, res: Response) {
  res.send(await queries.getUserAccOverview(req.userId));
}

/**
 * Update the user profile with the latest information
 */
export async function updateProfile(req: Request, res: Response) {
  const userId = req.userId;

  const patch = z
    .object({
      fullName: z.string().min(1).optional(),
      phoneNumber: z.e164().optional(),
      email: z.email().optional(),
    })
    .refine((data) => data.fullName !== undefined || data.phoneNumber !== undefined || data.email !== undefined, {
      message: "At least one field must be provided",
    })
    .parse(req.body);

  const updated = await queries.updateUserProfile(userId, patch);

  if (!updated) {
    return res.status(404).json({ error: "User not found" });
  }

  return res.json(updated);
}

/**
 * Return the authenticated user's profile information
 */
export async function getUserProfile(req: Request, res: Response) {
  const userId = req.userId;

  const profile = await queries.getUserProfile(userId);
  if (!profile) {
    return res.status(404).json({ error: "User not found" });
  }

  return res.json(profile);
}

/** Refresh an authenticated session by rotating the refresh token and issuing a new access token. */
export async function refreshSession(req: Request, res: Response) {
  const oldRefreshToken = z.string().parse(req.body.refreshToken);

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);
  const newRefreshToken = generateRefreshToken();

  const userId = await queries.resetRefreshToken(oldRefreshToken, newRefreshToken, expiresAt);
  if (userId === null) {
    return res.status(401).json({ error: "Invalid or expired refresh token" });
  }

  const accessToken = generateAccessToken(userId);
  res.json({ accessToken, refreshToken: newRefreshToken });
}
