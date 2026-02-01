import { Request, Response } from "express";
import z from "zod";
import * as queries from "../db/queries/index.js";

export async function transferMoney(req: Request, res: Response) {
  const { recipient: recipientPhoneNumber, amount } = z
    .object({
      recipient: z.e164(),
      amount: z.number().positive().multipleOf(0.01),
    })
    .parse(req.body);

  const recipient = await queries.getUserByPhoneNumber(recipientPhoneNumber);
  if (!recipient) {
    return res.status(400).json({ error: "No existing user with specified phone number" });
  }

  const transactionId = await queries.transferMoney(req.userId, recipient.userId, amount);
  if (transactionId === null) {
    return res.status(400).json({ error: "Insufficient funds" });
  }

  return res.status(200).json({ transactionId });
}

/**
 * Returns the transaction history for a given user ID
 */
export async function getTransactionHistory(req: Request, res: Response) {
  const transactionHistory = await queries.getTransactionHistory(req.userId);

  if (!transactionHistory) {
    return res.status(404).json({ error: "Transaction history not found" });
  }

  return res.json(transactionHistory);
}
