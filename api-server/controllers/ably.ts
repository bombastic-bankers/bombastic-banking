import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import Ably from "ably";
import { ABLY_API_KEY, JWT_SECRET } from "../env.js";

export async function ablyAuth(req: Request, res: Response) {
  console.log(`ably auth hit`);

  const atmToken = req.header("X-ATM-Token");
  if (!atmToken) {
    console.log(`no atm token`);
    return res.status(401).send();
  }

  let atmId: string;
  try {
    const payload = jwt.verify(atmToken, JWT_SECRET) as jwt.JwtPayload;
    if (!payload.sub) {
      console.log(`no payload sub`);
      return res.status(401).send();
    }
    atmId = payload.sub;
  } catch (error) {
    console.log(`jwt failed validation`);
    return res.status(401).send();
  }

  const ably = new Ably.Rest({ key: ABLY_API_KEY });
  const tokenRequest = await ably.auth.createTokenRequest({ clientId: atmId });
  return res.json(tokenRequest);
}
