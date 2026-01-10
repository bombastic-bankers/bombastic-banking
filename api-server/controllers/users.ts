import jwt from "jsonwebtoken";
import * as queries from "../db/queries/index.js";
import { JWT_SECRET } from "../env.js";
import { Request, Response } from "express";
import z from "zod";

export async function signUp(req: Request, res: Response) {
  const userInit = z
    .object({
      fullName: z.string().min(1),
      phoneNumber: z.e164(),
      email: z.email(),
      pin: z.string().regex(/[0-9]{6}/),
    })
    .parse(req.body);

  const created = await queries.createUser(userInit);
  if (!created) {
    return res.status(409).json({ error: "Email already in use" });
  }

  return res.status(201).send();
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

  const token = jwt.sign({ userId: user.userId }, JWT_SECRET, {
    expiresIn: "2m",
  });

  res.json({ token });
}

export async function getUserInfo(req: Request, res: Response) {
  res.send(await queries.getUserInfo(req.userId));
}

/**
 * update profile
 */
const updateProfileBodySchema = z
  .object({
    fullName: z.string().min(1).optional(),
    phoneNumber: z.e164().optional(),
    email: z.email().optional()
  })
  .refine(
    (data) => data.fullName !== undefined || data.phoneNumber !== undefined || data.email !== undefined,
    { message: "At least one field must be provided" }
  );


export async function updateProfile(req: Request, res: Response) {
  const userId = req.userId;
    if (!userId) return res.status(401).json({ error: "Unauthorized" });

    const patch = updateProfileBodySchema.parse(req.body);

    const updated = await queries.updateUserProfile(userId, patch);

    if (!updated) {
      return res.status(404).json({ error: "User not found" });
    }

    return res.json(updated);
}

/**
 * get user profile
 */

export async function getUserProfile(req: Request, res: Response) {
  const userId = req.userId;
  if (!userId) {
    return res.status(401).json({ error: "Unauthorized" });
  }

  const profile = await queries.getUserProfile(userId);

  if (!profile) {
    return res.status(404).json({ error: "User not found" });
  }

  return res.json(profile);
}
