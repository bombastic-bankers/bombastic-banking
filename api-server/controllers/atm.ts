import { Request, Response } from "express";
import * as realtime from "../realtime.js";
import * as queries from "../db/queries/index.js";
import { z } from "zod";

export async function indicateTouchless(req: Request, res: Response) {
  const atmId = +req.params.atmId;
  if (isNaN(atmId)) {
    return res.status(400).json({ error: "Invalid ATM ID" });
  }
  if (!(await queries.atmExists(atmId))) {
    return res.status(404).json({ error: "No ATM with specified ID" });
  }

  const hasSession = await queries.acquireTouchlessSession(req.userId, atmId);
  if (!hasSession) {
    return res
      .status(409)
      .json({ error: "Unable to acquire touchless session" });
  }

  await realtime.sendToATM(atmId, "indicate-touchless");
  return res.status(200).send();
}

export async function returnToIdle(req: Request, res: Response) {
  const atmId = +req.params.atmId;
  if (isNaN(atmId)) {
    return res.status(400).json({ error: "Invalid ATM ID" });
  }

  const sessionEnded = await queries.terminateTouchlessSession(
    req.userId,
    atmId,
  );
  if (!sessionEnded) {
    return res.status(404).json({ error: "No such existing session" });
  }

  await realtime.sendToATM(atmId, "return-to-idle");
  return res.status(200).send();
}

export async function withdrawCash(req: Request, res: Response) {
  const atmId = +req.params.atmId;
  if (isNaN(atmId)) {
    return res.status(400).json({ error: "Invalid ATM ID" });
  }

  const { amount } = z
    .object({ amount: z.number().positive().multipleOf(0.01) })
    .parse(req.body);

  const hasSession = await queries.acquireTouchlessSession(req.userId, atmId);
  if (!hasSession) {
    return res
      .status(409)
      .json({ error: "Unable to acquire touchless session" });
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

  const hasSession = await queries.acquireTouchlessSession(req.userId, atmId);
  if (!hasSession) {
    return res
      .status(409)
      .json({ error: "Unable to acquire touchless session" });
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

  const hasSession = await queries.acquireTouchlessSession(req.userId, atmId);
  if (!hasSession) {
    return res
      .status(409)
      .json({ error: "Unable to acquire touchless session" });
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
