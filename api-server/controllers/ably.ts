import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import Ably from "ably";
import { ABLY_API_KEY, JWT_SECRET } from "../env.js";

/** Return an Ably token request that an ATM can use to authenticate to Ably. */
export async function ablyAuth(req: Request, res: Response) {
  // The X-ATM-Token header is used to authenticate the ATM
  const atmToken = req.header("X-ATM-Token");
  if (!atmToken) {
    return res.status(401).json({ error: "Missing ATM token" });
  }

  // Verify X-Token-Header as a JWT
  let atmId: string;
  try {
    const payload = jwt.verify(atmToken, JWT_SECRET) as jwt.JwtPayload;
    if (!payload.sub) {
      return res.status(401).json({ error: "Missing sub in ATM token" });
    }
    atmId = payload.sub;
  } catch (error) {
    return res.status(401).json({ error: "Invalid ATM token" });
  }

  // Return the Ably token request
  const ably = new Ably.Rest({ key: ABLY_API_KEY });
  const tokenRequest = await ably.auth.createTokenRequest({ clientId: atmId });
  return res.json(tokenRequest);
}
