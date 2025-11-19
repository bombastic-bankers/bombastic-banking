import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import * as queries from "../db/queries/index.js";
import { JWT_SECRET } from "../env.js";
import { Request, Response } from "express";
import z from "zod";

export async function signUp(req: Request, res: Response) {
  const { fullName, phoneNumber, email, password } = z
    .object({
      fullName: z.string(),
      phoneNumber: z.string(),
      email: z.string(),
      password: z.string(),
    })
    .parse(req.body);

  const created = await queries.createUser({
    fullName,
    phoneNumber,
    email,
    hashedPassword: await bcrypt.hash(password, 10),
  });

  if (!created) {
    return res.status(409).json({ error: "Email already in use" });
  }

  return res.status(201).send();
}

export async function login(req: Request, res: Response) {
  const { email, password } = z
    .object({ email: z.string(), password: z.string() })
    .parse(req.body);
  const user = await queries.getUserByEmail(email);

  if (user === null) {
    return res.status(400).json({ error: "Incorrect email or password" });
  }

  if (!(await bcrypt.compare(password, user.hashedPassword))) {
    return res.status(400).json({ error: "Incorrect email or password" });
  }

  const token = jwt.sign({ userId: user.userId }, JWT_SECRET, {
    expiresIn: "2m",
  });

  res.json({ token });
}

export async function getUserInfo(req: Request, res: Response) {
  res.send(await queries.getUserInfo(req.userId));
}
