import { Request, Response } from "express";
import twilio from "twilio";
import { z } from "zod";
import nodemailer from "nodemailer";
import crypto from "crypto";
import * as queries from "../db/queries/index.js";
import { eq } from "drizzle-orm";
import { emailVerificationCodes } from "../db/schema.js";
import {
  TWILIO_SID,
  TWILIO_AUTH,
  TWILIO_VERIFY_SERVICE,
  MOCK_TWILIO_SMS,
} from "../env.js";
import { sendVerificationEmail } from "./services/emailVerificationService.js";
import { db } from "../db/index.js";

const client = twilio(TWILIO_SID, TWILIO_AUTH);
const VERIFY_SERVICE = TWILIO_VERIFY_SERVICE;

const mockOtpStore = new Map<string, string>();

/** Generate a random email verification token */
export function generateEmailToken() {
  const token = crypto.randomBytes(32).toString("hex");
  const expiry = new Date();
  expiry.setHours(expiry.getHours() + 24);
  return { token, expiry };
}

/** Send a phone OTP */
export async function sendPhoneOTP(req: Request, res: Response) {
  const { phoneNumber } = z
    .object({
      phoneNumber: z.string(),
    })
    .parse(req.body);

  try {
    if (MOCK_TWILIO_SMS) {
      const mockOtp = Math.floor(100000 + Math.random() * 900000).toString();
      mockOtpStore.set(phoneNumber, mockOtp);
      console.log("Mock OTP for", phoneNumber, ":", mockOtp);
      return res.json({ message: "Mock OTP sent (check terminal)" });
    }

    await client.verify.v2.services(VERIFY_SERVICE).verifications.create({
      to: phoneNumber,
      channel: "sms",
    });

    res.json({ message: "OTP sent successfully" });
  } catch (err) {
    console.error("SEND OTP ERROR:", err);
    res.status(500).json({ error: "Failed to send OTP" });
  }
}

/** Verify a phone OTP */
export async function verifyPhoneOTP(req: Request, res: Response) {
  const { phoneNumber, otp } = z
    .object({
      phoneNumber: z.string(),
      otp: z.string().length(6),
    })
    .parse(req.body);
  console.log("VERIFY PHONE:", phoneNumber, "OTP:", otp);

  try {
    if (MOCK_TWILIO_SMS) {
      const storedOtp = mockOtpStore.get(phoneNumber);

      const isTestEnv = process.env.NODE_ENV === 'test';
      const isValid = (otp === storedOtp) || (isTestEnv && otp === '123456');

      if (isValid) {
        mockOtpStore.delete(phoneNumber);
        return res.json({
          verified: true,
          message: "Mock verification successful",
        });
      }
      
      return res.status(400).json({
        verified: false,
        error: "Invalid OTP",
      });
    }

    const result = await client.verify.v2
      .services(VERIFY_SERVICE)
      .verificationChecks.create({
        to: phoneNumber,
        code: otp,
      });

    if (result.status === "approved") {
      return res.json({ verified: true });
    }

    res.status(400).json({ verified: false, error: "Invalid OTP" });
  } catch (err) {
    console.error("VERIFY OTP ERROR:", err);
    res.status(500).json({ error: "OTP verification failed" });
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
      return res
        .status(400)
        .send("<h1>Invalid Link</h1><p>The verification token is missing </p>");
    }
    const { token } = validation.data;

    const record = await queries.getEmailVerificationByToken(token);

    if (!record) {
      return res
        .status(400)
        .send(
          "<h1>Invalid Link</h1><p>This verification link is invalid or has already been used.</p>"
        );
    }

    if (new Date() > record.expiresAt) {
      return res
        .status(400)
        .send(
          "<h1>Expired Link</h1><p>This link has expired. Please request a new one from the app.</p>"
        );
    }
    await db
      .update(emailVerificationCodes)
      .set({ verifiedAt: new Date() })
      .where(eq(emailVerificationCodes.id, record.id));

    res.send(`
      <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
        <h1 style="color: #28a745;">Verification Successful!</h1> 
        <p>Your email has been verified. You can now log in to the app.</p>
      </div>
    `);
  } catch (err) {
    res
      .status(500)
      .send("An error occurred during verification. Please try again later.");
  }
}

/** Request email verification */
export async function requestEmailVerification(req: Request, res: Response) {
  try {
    const { email } = z.object({ email: z.string().email() }).parse(req.body);

    const { token, expiry } = generateEmailToken();

    await queries.saveEmailToken(email, token, expiry);

    await sendVerificationEmail(email, token);

    res.json({ message: "Verification email sent!" });
  } catch (err) {
    console.error("EMAIL_REQ_ERROR:", err);
    res.status(500).json({ error: "Failed to send verification email" });
  }
}
