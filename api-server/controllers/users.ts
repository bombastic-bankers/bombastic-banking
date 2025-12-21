import jwt from "jsonwebtoken";
import * as queries from "../db/queries/index.js";
import { JWT_SECRET } from "../env.js";
import { Request, Response } from "express";
import z from "zod";
import crypto from "crypto";
import { sendVerificationEmail, generateEmailToken,autoSendOTP} from "./verify.js";

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

  // generate email token
  const emailToken = crypto.randomBytes(32).toString("hex");
  const emailTokenExpiry = new Date();
  emailTokenExpiry.setHours(emailTokenExpiry.getHours() + 24);

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
    return res.status(400).json({ error: "Incorrect email or PIN" });
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
  const token = jwt.sign({ userId: user.userId }, JWT_SECRET, {
    expiresIn: "2m",
  });

  res.json({ token });
}

export async function getUserInfo(req: Request, res: Response) {
  res.send(await queries.getUserInfo(req.userId));
}
