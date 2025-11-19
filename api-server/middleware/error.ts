import { Request, Response, NextFunction } from "express";
import z from "zod";

export async function validationError(
  err: any,
  req: Request,
  res: Response,
  next: NextFunction,
) {
  if (!(err instanceof z.ZodError)) return next(err);

  const flattenedError = z.flattenError(err);
  res.status(400).json({
    error:
      Object.keys(flattenedError.fieldErrors).length > 0
        ? flattenedError.fieldErrors
        : flattenedError.formErrors,
  });
}

export async function anyError(
  err: any,
  req: Request,
  res: Response,
  next: NextFunction,
) {
  console.error(err);
  res.status(500).json({
    error: err instanceof Error ? err.message : err,
  });
}
