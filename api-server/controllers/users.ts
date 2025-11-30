import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import * as queries from "../db/queries/index.js";
import { JWT_SECRET } from "../env.js";
import { Request, Response } from "express";
import z from "zod";
import { generateAuthTokens } from "../utils/tokenService"; // for Refresh tokens
import { db } from "../db"; 
import { refreshTokens } from "../db/schema";
import { eq } from "drizzle-orm";

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

// export async function login(req: Request, res: Response) {
//   const { email, password } = z
//     .object({ email: z.string(), password: z.string() })
//     .parse(req.body);
//   const user = await queries.getUserByEmail(email);

//   if (user === null) {
//     return res.status(400).json({ error: "Incorrect email or password" });
//   }

//   if (!(await bcrypt.compare(password, user.hashedPassword))) {
//     return res.status(400).json({ error: "Incorrect email or password" });
//   }

//   const token = jwt.sign({ userId: user.userId }, JWT_SECRET, {
//     expiresIn: "2m",
//   });

//   res.json({ token });
// }

// updated login function (with refresh token)
export async function login(req: Request, res: Response) {
  const { email, password } = z
    .object({ email: z.string(), password: z.string() })
    .parse(req.body)

    const user = await queries.getUserByEmail(email);

    if (user === null) {
      return res.status(400).json({ error: "Incorrect email or password" });
    }

    if (!(await bcrypt.compare(password, user.hashedPassword))) {
    return res.status(400).json({ error: "Incorrect email or password" });
  }

    const { accessToken, refreshToken } = await generateAuthTokens(user.userId);

    res.cookie("refreshToken", refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 30 * 24 * 60 * 60 * 1000
    });

    res.json({ accessToken})
}

export async function getUserInfo(req: Request, res: Response) {
  res.send(await queries.getUserInfo(req.userId));
}

export async function refreshSession(req: Request, res: Response) {
  const incomingRefreshToken = req.cookies.refreshToken;

  if (!incomingRefreshToken) {
    return res.status(401).json({ error: "No refresh token provided"})
  }

  try {
    const [storedToken] = await db
    .select()
    .from(refreshTokens)
    .where(eq(refreshTokens.token, incomingRefreshToken))
    .limit(1);

    if (!storedToken || new Date() > storedToken.expiresAt) {
      res.clearCookie("refreshToken");
      return res.status(401).json({ error: "Invalid or expired refresh token"});
    }

    await db
      .delete(refreshTokens)
      .where(eq(refreshTokens.id, storedToken.id));
    
    const { accessToken, refreshToken } = await generateAuthTokens(storedToken.userId);

    res.cookie("refreshToken", refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict", 
      maxAge: 30 * 24 * 60 * 60 * 100,
    });

    res.json({ accessToken });

  } catch (err) {
    console.error("Refresh error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
}
