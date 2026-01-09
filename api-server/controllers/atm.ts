import { Request, Response } from "express";
import * as realtime from "../realtime.js";
import * as queries from "../db/queries/index.js";
import { z } from "zod";

/**
 * Command the ATM to withdraw the specified amount of cash.
 */
export async function withdrawCash(req: Request, res: Response) {
  const { amount } = z.object({ amount: z.number().positive().multipleOf(0.01) }).parse(req.body);

  if (!(await queries.ensureTouchlessSession(req.userId, req.atmId))) {
    return res.status(409).json({ error: "Unable to start touchless session" });
  }

  // Command the ATM to withdraw the specified amount
  await realtime.sendToATM(req.atmId, "withdraw", { amount });
  // Wait for the ATM to finish withdrawing the cash
  await realtime.waitForATM(req.atmId, "withdraw-ready");

  await queries.withdrawCash(req.userId, amount);
  return res.status(200).send();
}

/**
 * Command the ATM to allow a cash deposit.
 */
export async function startCashDeposit(req: Request, res: Response) {
  if (!(await queries.ensureTouchlessSession(req.userId, req.atmId))) {
    return res.status(409).json({ error: "Unable to start touchless session" });
  }

  await realtime.sendToATM(req.atmId, "deposit-start");
  return res.status(200).send();
}

/**
 * Command the ATM to count the deposited cash and return the amount.
 */
export async function countCashDeposit(req: Request, res: Response) {
  if (!(await queries.ensureTouchlessSession(req.userId, req.atmId))) {
    return res.status(409).json({ error: "Unable to start touchless session" });
  }

  // Command the ATM to count the cash deposit
  await realtime.sendToATM(req.atmId, "deposit-count");
  // Wait for the ATM to finish counting the cash
  const result = await realtime.waitForATM<{ amount: number }>(req.atmId, "deposit-review");
  return res.status(200).json(result);
}

/**
 * Command the ATM to finalize the cash deposit.
 */
export async function confirmCashDeposit(req: Request, res: Response) {
  if (!(await queries.ensureTouchlessSession(req.userId, req.atmId))) {
    return res.status(409).json({ error: "Unable to start touchless session" });
  }

  // Command the ATM to finalize the cash deposit
  await realtime.sendToATM(req.atmId, "deposit-confirm");

  return res.status(200).send();
}

/**
 * Command the ATM to cancel the cash deposit, returning the
 * cash to the user and allowing for another deposit attempt.
 */
export async function cancelCashDeposit(req: Request, res: Response) {
  if (!(await queries.ensureTouchlessSession(req.userId, req.atmId))) {
    return res.status(409).json({ error: "Unable to start touchless session" });
  }

  await realtime.sendToATM(req.atmId, "deposit-cancel");
  return res.status(200).send();
}

/**
 * Command the ATM to return to idle state, ending the touchless session.
 */
export async function exit(req: Request, res: Response) {
  if (!(await queries.endTouchlessSession(req.userId, req.atmId))) {
    return res.status(404).json({ error: "User does not have session with specified ATM" });
  }

  await realtime.sendToATM(req.atmId, "exit");
  return res.status(200).send();
}
