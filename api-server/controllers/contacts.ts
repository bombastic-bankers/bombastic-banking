import * as queries from "../db/queries/index.js";
import { Request, Response } from "express";
import z from "zod";

export async function getContactsByPhoneNumber(req: Request, res: Response) {
  const phoneNumbers = z.e164().array().parse(req.body);

  if (phoneNumbers.length === 0) {
    return res.status(200).json([]);
  }

  const contacts = await queries.getContactsByPhoneNumber(phoneNumbers);
  if (!contacts) {
    return res.status(400).json({ error: "Invalid list of phone numbers" });
  }

  return res.status(200).json(contacts);
}
