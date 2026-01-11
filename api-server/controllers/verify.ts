import { Request, Response } from "express";
import twilio from "twilio";
import { z } from "zod";
import nodemailer from "nodemailer";
import crypto from "crypto";
import * as queries from "../db/queries/index.js";

import { EMAIL_USER,EMAIL_PASS,BASE_URL,TWILIO_SID,TWILIO_AUTH,TWILIO_VERIFY_SERVICE,MOCK_EMAIL,MOCK_TWILIO_SMS} from "../env.js";

const client = twilio(TWILIO_SID, TWILIO_AUTH);
const VERIFY_SERVICE = TWILIO_VERIFY_SERVICE;

// send OTP
export async function sendPhoneOTP(req: Request, res: Response) {
  const { phoneNumber } = z.object({
    phoneNumber: z.string(),
  }).parse(req.body);

  try {
    const user = await queries.getUserByPhoneNumber(phoneNumber);
    if (!user) {
      return res.status(404).json({ error: "Phone number not registered" });
    }

    if (MOCK_TWILIO_SMS) {
      const mockOtp = Math.floor(100000 + Math.random() * 900000).toString();
      console.log("Mock OTP for", phoneNumber, ":", mockOtp);
      return res.json({ message: "Mock OTP sent (check terminal)" });
    }

    await client.verify.v2
      .services(VERIFY_SERVICE)
      .verifications.create({
        to: phoneNumber,
        channel: "sms",
      });

    res.json({ message: "OTP sent successfully" });
  } catch (err) {
    console.error("SEND OTP ERROR:", err);
    res.status(500).json({ error: "Failed to send OTP" });
  }
}

// verify OTP
export async function verifyPhoneOTP(req: Request, res: Response) {
  const { phoneNumber, otp } = z.object({
    phoneNumber: z.string(),
    otp: z.string().length(6),
  }).parse(req.body);
  console.log("VERIFY PHONE:", phoneNumber, "OTP:", otp); 

  try {
    const user = await queries.getUserByPhoneNumber(phoneNumber);
    if (!user) {
      return res.status(404).json({ error: "Phone number not registered" });
    }

    if (MOCK_TWILIO_SMS) {
      console.log("Mock verify:", phoneNumber, "OTP:", otp);
      await queries.updatePhoneVerified(user.userId, true);
      return res.json({ verified: true });
    }

    const result = await client.verify.v2
      .services(VERIFY_SERVICE)
      .verificationChecks.create({
        to: phoneNumber,
        code: otp,
      });

    if (result.status === "approved") {
      await queries.updatePhoneVerified(user.userId, true);
      return res.json({ verified: true });
    }

    res.status(400).json({ verified: false, error: "Invalid OTP" });
  } catch (err) {
    console.error("VERIFY OTP ERROR:", err);
    res.status(500).json({ error: "OTP verification failed" });
  }
}

// Nodemailer Config
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: EMAIL_USER,
    pass: EMAIL_PASS,
  },
});
export function generateEmailToken() {
  const token = crypto.randomBytes(32).toString("hex");
  const expiry = new Date();
  expiry.setHours(expiry.getHours() + 24);
  return { token, expiry };
}

// verify email link
export async function verifyEmailLink(req: Request, res: Response) {
  try {
  
    const validation = z.object({
      token: z.string(),
    }).safeParse(req.query);

    if (!validation.success) {
      return res.status(400).send(`
        <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
          <h1 style="color: #dc3545;">Invalid Link</h1>
          <p>The verification token is missing or malformed.</p>
        </div>
      `);
    }

    const { token } = validation.data;

    // Fetch user by token
    const user = await queries.getUserByEmailToken(token);

    if (!user) {
      return res.status(400).send("<h1>Invalid Link</h1><p>This verification link is invalid or has already been used.</p>");
    }

    if (user.emailTokenExpiry && new Date() > user.emailTokenExpiry) {
      return res.status(400).send("<h1>Expired Link</h1><p>This link has expired. Please request a new one from the app.</p>");
    }

    if (user.emailverified) {
        return res.send("<h1>Already Verified</h1><p>You have already verified your email. You can log in.</p>");
    }

    // Update user to set email as verified
    await queries.verifyUserEmail(user.userId);

    res.send(`
      <div style="font-family: sans-serif; text-align: center; padding-top: 50px;">
        <h1 style="color: #28a745;">Verification Successful!</h1>
        <p>Your email has been verified. You can now log in to the app.</p>
      </div>
    `);

  } catch (err) {
    console.error("EMAIL_VERIFY_ERROR:", err);
    res.status(500).send("An error occurred during verification. Please try again later.");
  }
}
// send verification email
export async function sendVerificationEmail(email: string, token: string) {
  const frontendUrl = BASE_URL;
  const link = `${frontendUrl}/verify/email/confirm?token=${token}`;

  // Mock email for testing
  if (MOCK_EMAIL) {
    console.log("\n--- [Mock Email Verification] ---");
    console.log('From: "OCBC Support" <' + EMAIL_USER + '>');
    console.log(`To: ${email}`);
    console.log(`Subject: Verify Your Account`);
    console.log(`Link: ${link}`);
    return;
  }

  await transporter.sendMail({
    from: `"OCBC Support" <${EMAIL_USER}>`,
    to: email,
    subject: "Verify Your Account",
    html: `<p>Click <a href="${link}">here</a> to verify your email. This link expires in 24 hours.</p>`,
  });
}

// auto send OTP
export async function autoSendOTP(phoneNumber: string) {
    if (MOCK_TWILIO_SMS) {
        const mockOtp = Math.floor(100000 + Math.random() * 900000).toString();
        console.log(`[Auto-Mock OTP] to ${phoneNumber}: ${mockOtp}`);
        return;
    }
    await client.verify.v2.services(VERIFY_SERVICE)
        .verifications.create({ to: phoneNumber, channel: "sms" });
}
