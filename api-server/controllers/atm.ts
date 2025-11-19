import { Request, Response } from "express";
import { sendToATM, waitForATM } from "../pubsub.js";
import * as queries from "../db/queries/index.js";
import { z } from "zod";

export async function startTouchlessSession(req: Request, res: Response) {
  const atmId = +req.params.atmId;
  if (isNaN(atmId)) {
    return res.status(400).json({ message: "Invalid ATM ID" });
  }

  if (!(await queries.atmExists(atmId))) {
    return res.status(404).json({ message: "No ATM with specified ID" });
  }

  const sessionStarted = await queries.startTouchlessSession(req.userId, atmId);
  await sendToATM(atmId, "start-touchless-session");

  return sessionStarted
    ? res.status(200).send()
    : res.status(409).json({ message: "ATM already in use" });
}

export async function endTouchlessSession(req: Request, res: Response) {
  const atmId = +req.params.atmId;
  if (isNaN(atmId)) {
    return res.status(400).json({ message: "Invalid ATM ID" });
  }

  const sessionEnded = await queries.endTouchlessSession(req.userId, atmId);
  return sessionEnded
    ? res.status(200).send()
    : res.status(404).json({ message: "No such existing session" });
}

export async function withdrawCash(req: Request, res: Response) {
  const atmId = +req.params.atmId;
  if (isNaN(atmId)) {
    return res.status(400).json({ message: "Invalid ATM ID" });
  }

  const parsed = z
    .object({ amount: z.number().positive().multipleOf(0.01) })
    .safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ message: parsed.error.issues });
  }
  const { amount } = parsed.data;

  if (!(await queries.touchlessSessionExists(req.userId, atmId))) {
    return res.status(404).json({ message: "No touchless session found" });
  }

  // Command the ATM to withdraw the specified amount
  await sendToATM(atmId, "withdraw", { amount });
  // Wait for the ATM to finish withdrawing the cash
  await waitForATM(atmId, "withdraw-ready");

  await queries.updateLedgerForWithdrawal(req.userId, amount);
  return res.status(200).send();
}

export async function depositCash(req: Request, res: Response) {
  res.status(500).send();
}
