import jwt from "jsonwebtoken";
import { Request, Response, NextFunction } from "express";
import { JWT_SECRET } from "../env.js";

export function authenticate(req: Request, res: Response, next: NextFunction) {
  console.log(`general auth hit`);

  const auth = req.headers.authorization;

  if (!auth || !auth.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Missing or invalid auth token" });
  }

  const token = auth.split(" ")[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as jwt.JwtPayload;
    req.userId = decoded.userId; // attached decoded JWT payload
    next();
  } catch (err) {
    return res.status(401).json({ error: "Invalid or expired token" });
  }
}
