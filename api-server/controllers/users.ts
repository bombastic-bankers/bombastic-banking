import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import * as queries from "../db/queries/index.js";
import { JWT_SECRET } from "../env.js";
import { Request, Response } from "express";

export async function signUp(req: Request, res: Response) {
  const { fullName, phoneNumber, email, password } = req.body;

  if (!fullName || !phoneNumber || !email || !password) {
    return res.status(400).json({ error: "Missing fields" });
  }

  const newUser = await queries.createUser({
    fullName,
    phoneNumber,
    email,
    hashedPassword: await bcrypt.hash(password, 10),
  });

  res.status(201).json(newUser);
}

export async function login(req: Request, res: Response) {
  const { email, password } = req.body;
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
