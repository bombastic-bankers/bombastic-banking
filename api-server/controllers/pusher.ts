import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import { pusherServer } from "../pubsub";
import { JWT_SECRET, SERVER_SELF_AUTH_KEY } from "../env";

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
    jwt.verify(atmKey, JWT_SECRET);
    return res.send(pusherServer.authorizeChannel(socket_id, channel_name));
  } catch (error) {
    return res.status(401).send();
  }
}
