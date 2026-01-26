import { Request, Response } from "express";
import { z } from "zod";
import * as queries from "../db/queries/index.js";
import { sendOTP, checkOTP } from "../services/smsVerificationService.js";
import { checkEmailOTP } from "../services/emailVerificationService.js";

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

/** Verify Email using Twilio Verify */
export async function verifyEmailLink(req: Request, res: Response) {
  try {
    const { email, token } = req.query as { email?: string; token?: string };

    if (!email || !token) {
      return res.status(400).send(`
        <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
          <h1 style="color: #dc3545;">Verification Failed</h1>
          <p>Email or token missing.</p>
        </div>
      `);
    }

    const user = await queries.getUserByEmail(email);
    if (!user) {
      return res.status(404).send(`
        <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
          <h1 style="color: #dc3545;">Verification Failed</h1>
          <p>Email not registered.</p>
        </div>
      `);
    }

    const isApproved = await checkEmailOTP(email, token);

    if (isApproved) {
      await queries.verifyUserEmail(user.userId);

      return res.send(`
        <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
          <h1 style="color: #28a745;">Email Verified!</h1>
          <p>Your email has been successfully verified.</p>
        </div>
      `);
    } else {
      return res.status(400).send(`
        <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
          <h1 style="color: #dc3545;">Verification Failed</h1>
          <p>Invalid or expired token.</p>
        </div>
      `);
    }
  } catch (err) {
    console.error(err);
    res.status(500).send(`
      <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
        <h1 style="color: #dc3545;">Verification Failed</h1>
        <p>Something went wrong. Please try again later.</p>
      </div>
    `);
  }
}
