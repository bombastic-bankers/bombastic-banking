import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import { pusherServer } from "../pubsub.js";
import { JWT_SECRET, SERVER_SELF_AUTH_KEY } from "../env.js";

export async function pusherAuth(req: Request, res: Response) {
  const { socket_id, channel_name } = req.body;

  const serverKey = req.header("X-Server-Key");
  if (serverKey === SERVER_SELF_AUTH_KEY) {
    return res.send(pusherServer.authorizeChannel(socket_id, channel_name));
  }

  const atmKey = req.header("X-ATM-Key");
  if (!atmKey) {
    return res.status(401).send();
  }

  try {
    const payload = jwt.verify(atmKey, JWT_SECRET) as jwt.JwtPayload;
    if (channel_name !== `private-atm-${payload.sub}`) {
      return res.status(401).send();
    }

    return res.send(pusherServer.authorizeChannel(socket_id, channel_name));
  } catch (error) {
    return res.status(401).send();
  }
}
