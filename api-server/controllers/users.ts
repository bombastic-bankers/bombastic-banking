import jwt from "jsonwebtoken";
import * as queries from "../db/queries/index.js";
import { JWT_SECRET } from "../env.js";
import { Request, Response } from "express";
import z from "zod";
import * as queries from "../db/queries/index.js";
import { generateAuthTokens } from "../utils/tokenService";

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
    return res.status(401).json({ error: "Incorrect email or PIN" });
  }

  const token = jwt.sign({ userId: user.userId }, JWT_SECRET, {
    expiresIn: "2m",
  });

  res.json({ accessToken, refreshToken });
}

export async function getUserInfo(req: Request, res: Response) {
  res.send(await queries.getUserInfo(req.userId));
}

export async function refreshSession(req: Request, res: Response) {
  const incomingRefreshToken = req.body.refreshToken;

  if (!incomingRefreshToken) {
    return res.status(401).json({ error: "No refresh token provided" });
  }

  const storedToken = await queries.getRefreshToken(incomingRefreshToken);

  if (!storedToken || new Date() > storedToken.expiresAt) {
    return res.status(401).json({ error: "Invalid or expired refresh token" });
  }

  await queries.deleteRefreshToken(storedToken.id);

  const { accessToken, refreshToken } = await generateAuthTokens(storedToken.userId);

  res.json({ accessToken, refreshToken });
}
