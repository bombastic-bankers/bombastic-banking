import { Request, Response } from "express";
import { z } from "zod";
import * as queries from "../db/queries/index.js";
import { sendOTP, checkOTP } from "../services/smsVerificationService.js";
import { sendVerificationEmail, generateEmailToken } from "../services/emailVerificationService.js";

/**
 * Send OTP to authenticated user's phone number.
 */
export async function sendSMSVerification(req: Request, res: Response) {
  const user = await queries.getUserById(req.userId!);
  if (!user) {
    return res.status(404).json({ error: "User not found" });
  }

  await sendOTP(user.phoneNumber);
  res.json({ message: "OTP sent successfully" });
}

/**
 * Verify OTP for authenticated user's phone number.
 */
export async function confirmSMSVerification(req: Request, res: Response) {
  const { otp } = z.object({ otp: z.string().length(6) }).parse(req.body);

  const user = await queries.getUserById(req.userId!);
  if (!user) {
    return res.status(404).json({ error: "User not found" });
  }

  const isApproved = await checkOTP(user.phoneNumber, otp);
  if (isApproved) {
    await queries.updatePhoneVerified(user.userId, true);
    return res.json({ verified: true });
  }

  res.status(400).json({ verified: false });
}

/**
 * Send email verification to authenticated user's email.
 */
export async function sendEmailVerification(req: Request, res: Response) {
  const user = await queries.getUserById(req.userId!);
  if (!user) {
    return res.status(404).json({ error: "User not found" });
  }

  const { token, expiry } = generateEmailToken();
  await queries.saveEmailToken(user.userId, token, expiry);
  await sendVerificationEmail(user.email, token);

  res.json({ message: "Verification email sent successfully" });
}

/**
 * Verify email link.
 */
export async function confirmEmailVerification(req: Request, res: Response) {
  const validation = z.object({ token: z.string() }).safeParse(req.query);

  if (!validation.success) {
    return res.status(400).send(`
        <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
          <h1 style="color: #dc3545;">Invalid Link</h1>
          <p>The verification token is missing or malformed.</p>
        </div>
      `);
  }

  const { token } = validation.data;

  const user = await queries.verifyUserEmailByToken(token);

  if (!user) {
    return res.status(400).send(`
        <h1>Invalid Link</h1>
        <p>This verification link is invalid or has already been used.</p>
      `);
  }

  if (new Date() > user.emailTokenExpiry) {
    return res.status(400).send(`
        <h1>Expired Link</h1>
        <p>This link has expired. Please request a new one from the app.</p>
      `);
  }

  return res.send(`
    <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
      <h1 style="color: #28a745;">Verification Successful!</h1>
      <p>Your email has been verified. You can now log in to the app.</p>
    </div>
  `);
}
