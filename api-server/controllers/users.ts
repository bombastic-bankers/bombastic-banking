import { Request, Response } from "express";
import z from "zod";
import * as queries from "../db/queries/index.js";
import { generateAuthTokens } from "../services/auth.js";

/** Create a new user account with the provided credentials. */
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

/** Authenticate a user and issue access and refresh tokens. */
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

  const { accessToken, refreshToken } = await generateAuthTokens(user.userId);
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);
  await queries.setRefreshToken(user.userId, refreshToken, expiresAt);

  res.json({ accessToken, refreshToken });
}

/** Return the authenticated user's information. */
export async function getUserInfo(req: Request, res: Response) {
  res.send(await queries.getUserInfo(req.userId));
}

/** Refresh an authenticated session by rotating the refresh token and issuing a new access token. */
export async function refreshSession(req: Request, res: Response) {
  const oldRefreshToken = z.string().parse(req.body.refreshToken);

  const { accessToken, refreshToken: newRefreshToken } = await generateAuthTokens(req.userId);
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);

  const success = await queries.resetRefreshToken(oldRefreshToken, newRefreshToken, expiresAt);
  if (!success) {
    return res.status(401).json({ error: "Invalid or expired refresh token" });
  }

  res.json({ accessToken, refreshToken: newRefreshToken });
}
