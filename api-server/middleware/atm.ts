import { Request, Response, NextFunction } from "express";

export async function atmParam(req: Request, res: Response, next: NextFunction) {
  req.atmId = +req.params.atmId;
  if (isNaN(req.atmId)) {
    return res.status(400).json({ error: "Invalid ATM ID" });
  }

  next();
}
