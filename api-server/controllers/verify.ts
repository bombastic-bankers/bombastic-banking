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
      .parse(req.query);

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
    const { email, token } = z
      .object({
        email: z.string().email(),
        token: z.string().length(6),
      })
      .parse(req.query); 

    const user = await queries.getUserByEmail(email);
    if (!user) {
      return res.status(404).json({ error: "Email not registered" });
    }

    const isApproved = await checkEmailOTP(email, token);

    if (isApproved) {
      await queries.verifyUserEmail(user.userId);
      return res.json({ verified: true }); 
    }

    res.status(400).json({ verified: false, error: "Invalid email code" });
  } catch (err) {
    res.status(400).json({ error: "Missing or invalid parameters" });
  }
}