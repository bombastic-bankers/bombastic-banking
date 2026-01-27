import { Request, Response } from "express";
import { z } from "zod";
import * as queries from "../db/queries/index.js";
import { sendOTP, checkOTP } from "../services/smsVerificationService.js";
import {
  sendVerificationEmail,
  generateEmailToken,
} from "../services/emailVerificationService.js";

/** * Send OTP to phone number
 */
export async function sendPhoneOTP(req: Request, res: Response) {
  const { phoneNumber } = z
    .object({
      phoneNumber: z.string(),
    })
    .parse(req.body);

  const user = await queries.getUserByPhoneNumber(phoneNumber);
  if (!user) {
    return res.status(404).json({ error: "Phone number not registered" });
  }

  await sendOTP(phoneNumber);

  res.json({ message: "OTP sent successfully" });
}

/** * Verify OTP for phone number
 */
export async function verifyPhoneOTP(req: Request, res: Response) {
  try {
    const { phoneNumber, otp } = z
      .object({
        phoneNumber: z.string(),
        otp: z.string().length(6),
      })
      .parse(req.body);

    const user = await queries.getUserByPhoneNumber(phoneNumber);
    if (!user) {
      return res.status(404).json({ error: "Phone number not registered" });
    }
    const isApproved = await checkOTP(phoneNumber, otp);

    if (isApproved) {
      await queries.updatePhoneVerified(user.userId, true);
      return res.json({ verified: true });
    }

    res.status(400).json({ verified: false, error: "Invalid OTP" });
  } catch (err) {
    res.status(400).json({ error: "Missing or invalid query parameters" });
  }
}
/** Verify email link */
export async function verifyEmailLink(req: Request, res: Response) {
  try {
    const validation = z
      .object({
        token: z.string(),
      })
      .safeParse(req.query);

    if (!validation.success) {
      return res.status(400).send(`
        <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
          <h1 style="color: #dc3545;">Invalid Link</h1>
          <p>The verification token is missing or malformed.</p>
        </div>
      `);
    }

    const { token } = validation.data;

    const user = await queries.getUserByEmailToken(token);

    if (!user) {
      return res.status(400).send(`
        <h1>Invalid Link</h1>
        <p>This verification link is invalid or has already been used.</p>
      `);
    }

    if (user.emailVerified) {
      return res.send(`
        <h1>Already Verified</h1>
        <p>You have already verified your email. You can log in.</p>
      `);
    }

    if (user.emailTokenExpiry && new Date() > user.emailTokenExpiry) {
      return res.status(400).send(`
        <h1>Expired Link</h1>
        <p>This link has expired. Please request a new one from the app.</p>
      `);
    }

    await queries.verifyUserEmail(user.userId);

    return res.send(`
      <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
        <h1 style="color: #28a745;">Verification Successful!</h1>
        <p>Your email has been verified. You can now log in to the app.</p>
      </div>
    `);
  } catch (err) {
    console.error("EMAIL_VERIFY_ERROR:", err);
    return res
      .status(500)
      .send("An error occurred during verification. Please try again later.");
  }
}
