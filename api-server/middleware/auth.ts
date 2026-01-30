import jwt from "jsonwebtoken";
import { Request, Response, NextFunction } from "express";
import env from "../env.js";

export function authenticate(req: Request, res: Response, next: NextFunction) {
  const auth = req.headers.authorization;

  if (!auth || !auth.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Missing or invalid auth token" });
  }

  const token = auth.split(" ")[1];

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET) as jwt.JwtPayload;

    if (!decoded.sub) {
      return res.status(401).json({ error: "Missing sub in auth token" });
    }

    const match = decoded.sub.match(/^user\|(\d+)$/);
    if (!match) {
      return res.status(401).json({ error: "Invalid sub in auth token" });
    }

    req.userId = +match[1];
    req.userVerified = decoded.email_verified && decoded.phone_verified;

    next();
  } catch (err) {
    return res.status(401).json({ error: "Invalid or expired token" });
  }
}

/**
 * Require users to have their email and phone number verified.
 */
export function requireVerified(req: Request, res: Response, next: NextFunction) {
  if (!req.userVerified) {
    return res.status(403).json({
      error: "Account not fully verified",
      message: "Please ensure both your email and phone number are verified.",
    });
  }

  next();
}
