import { Request, Response } from "express";
import * as realtime from "../realtime.js";
import * as queries from "../db/queries/index.js";
import { z } from "zod";

export async function startTouchlessSession(req: Request, res: Response) {
  const atmId = +req.params.atmId;
  if (isNaN(atmId)) {
    return res.status(400).json({ error: "Invalid ATM ID" });
  }

  if (!(await queries.atmExists(atmId))) {
    return res.status(404).json({ error: "No ATM with specified ID" });
  }

  const sessionStarted = await queries.startTouchlessSession(req.userId, atmId);
  await realtime.sendToATM(atmId, "start-touchless-session");

  return sessionStarted
    ? res.status(200).send()
    : res.status(409).json({ error: "ATM already in use" });
}

export async function endTouchlessSession(req: Request, res: Response) {
  const atmId = +req.params.atmId;
  if (isNaN(atmId)) {
    return res.status(400).json({ error: "Invalid ATM ID" });
  }

  const sessionEnded = await queries.endTouchlessSession(req.userId, atmId);

  if (sessionEnded) {
    await realtime.sendToATM(atmId, "end-touchless-session");
    return res.status(200).send();
  }

  return res.status(404).json({ error: "No such existing session" });
}

export async function withdrawCash(req: Request, res: Response) {
  const atmId = +req.params.atmId;
  if (isNaN(atmId)) {
    return res.status(400).json({ error: "Invalid ATM ID" });
  }

  const { amount } = z
    .object({ amount: z.number().positive().multipleOf(0.01) })
    .parse(req.body);

  if (!(await queries.touchlessSessionExists(req.userId, atmId))) {
    return res.status(404).json({ error: "No touchless session found" });
  }

  console.log(`sending withdraw event`);

  // Command the ATM to withdraw the specified amount
  await realtime.sendToATM(atmId, "withdraw", { amount });
  // Wait for the ATM to finish withdrawing the cash
  await realtime.waitForATM(atmId, "withdraw-ready");

  await queries.updateLedgerForWithdrawal(req.userId, amount);
  return res.status(200).send();
}

export async function initiateCashDeposit(req: Request, res: Response) {
  const atmId = +req.params.atmId;
  if (isNaN(atmId)) {
    return res.status(400).json({ error: "Invalid ATM ID" });
  }

  if (!(await queries.touchlessSessionExists(req.userId, atmId))) {
    return res.status(404).json({ error: "No touchless session found" });
  }

  // Command the ATM to allow a cash deposit
  await realtime.sendToATM(atmId, "initiate-deposit");
  return res.status(200).send();
}

export async function confirmCashDeposit(req: Request, res: Response) {
  const atmId = +req.params.atmId;
  if (isNaN(atmId)) {
    return res.status(400).json({ error: "Invalid ATM ID" });
  }

  if (!(await queries.touchlessSessionExists(req.userId, atmId))) {
    return res.status(404).json({ error: "No touchless session found" });
  }

  // Command the ATM to store the cash deposit
  await realtime.sendToATM(atmId, "confirm-deposit");
  // Wait for the ATM to finish counting the cash
  const result = await realtime.waitForATM<{ amount: number }>(
    atmId,
    "deposit-collected",
  );
  return res.status(200).json(result);
}
