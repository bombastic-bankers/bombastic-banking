import JWT_SECRET from "../env.js";
import jwt from "jsonwebtoken";
import { Request, Response } from "express";
import z from "zod";
import * as queries from "../db/queries/index.js";
import { generateAuthTokens } from "../services/auth.js";
import crypto from "crypto";
import { sendVerificationEmail } from "./services/emailVerificationService.js";
import { autoSendOTP } from "./services/smsVerificationService.js";
import { generateEmailToken } from "./verify.js";

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

  const { token: emailToken, expiry: emailTokenExpiry } = generateEmailToken();

  // create user
  const created = await queries.createUser({
    ...userInit,
    emailToken,
    emailTokenExpiry,
  });

  if (!created) {
    return res.status(500).json({ error: "Failed to create account" });
  }

  // automatically send verification email and OTP
  try {
    await sendVerificationEmail(userInit.email, emailToken);
    await autoSendOTP(userInit.phoneNumber);
    
    return res.status(201).json({ 
      message: "Registration successful! Please verify your email and phone number." 
    });
  } catch (error) {
    console.error("AUTO_SEND_ERROR:", error);
    return res.status(201).json({ 
      message: "Account created, but verification codes failed to send. Please request a resend." 
    });
  }
}


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
  // If either one is false, login fails
  if (!user.emailverified || !user.phoneverified) {
    return res.status(403).json({ 
      error: "Account not fully verified", 
      // emailVerified: user.emailverified,
      // phoneVerified: user.phoneverified,
      message: "Please ensure both your email and phone number are verified."
    });
  }
  const { accessToken, refreshToken } = await generateAuthTokens(user.userId);
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);
  await queries.setRefreshToken(user.userId, refreshToken, expiresAt);

  res.json({ accessToken, refreshToken });
}

export async function getUserInfo(req: Request, res: Response) {
  res.send(await queries.getUserAccOverview(req.userId));
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
      email: z.email().optional()
    })
    .refine(
      (data) => data.fullName !== undefined ||
        data.phoneNumber !== undefined ||
        data.email !== undefined,
      { message: "At least one field must be provided" }
    )
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

  const profile = await queries.getUserAccOverview(userId);
  if (!profile) {
    return res.status(404).json({ error: "User not found" });
  }

  return res.json(profile);
}

/** Refresh an authenticated session by rotating the refresh token and issuing a new access token. */
export async function refreshSession(req: Request, res: Response) {
  const oldRefreshToken = z.string().parse(req.body.refreshToken);

  const { accessToken, refreshToken: newRefreshToken } = await generateAuthTokens(req.userId);
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);

  const success = await queries.resetRefreshToken(oldRefreshToken, newRefreshToken, expiresAt);
  if (!success) {
    return res.status(401).json({ error: "Invalid or expired refresh token" });
  }

  res.json({ accessToken, refreshToken: newRefreshToken });
}
