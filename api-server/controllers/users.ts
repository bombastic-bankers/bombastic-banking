import jwt from "jsonwebtoken";
import * as queries from "../db/queries/index.js";
import { JWT_SECRET } from "../env.js";
import { Request, Response } from "express";
import z from "zod";
import crypto from "crypto";

/** Sign up a new user */
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

  const existingPhone = await queries.getUserByPhoneNumber(
    userInit.phoneNumber
  );
  if (existingPhone) {
    return res
      .status(409)
      .json({ error: "This phone number is already in use." });
  }
  const verificationRecord = await queries.getEmailVerificationByEmail(
    userInit.email
  );

  if (!verificationRecord || !verificationRecord.verifiedAt) {
    return res.status(403).json({
      error:
        "Verification incomplete. Please verify your email and phone first.",
    });
  }
  if (new Date() > new Date(verificationRecord.expiresAt)) {
    return res
      .status(403)
      .json({ error: "Verification expired. Please request a new link." });
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
  await queries.deleteEmailToken(verificationRecord.id);

  return res
    .status(201)
    .json({ message: "Registration successful! You can now login." });
}

/* Log in an existing user */

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

  const token = jwt.sign({ userId: user.userId }, JWT_SECRET, {
    expiresIn: "2m",
  });
  res.json({ token });
}

export async function getUserInfo(req: Request, res: Response) {
  res.send(await queries.getUserInfo(req.userId));
}
