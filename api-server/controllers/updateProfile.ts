import type { Request, Response } from "express";
import { ZodError } from "zod";
import { z } from "zod";
import * as queries from "../db/queries/index.js";

const updateProfileBodySchema = z
  .object({
    fullName: z.string().min(1).optional(),
    // exactly 8 digits
    phoneNumber: z.string().regex(/^\d{8}$/).optional(),
    email: z.email().optional()
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field must be provided"
  });

export async function updateProfile(req: Request, res: Response) {
  try {
    const userId = req.userId;
    if (!userId) return res.status(401).json({ error: "Unauthorized" });

    const patch = updateProfileBodySchema.parse(req.body);

    const updated = await queries.updateUserProfile(userId, patch);

    if (!updated) {
      return res.status(404).json({ error: "User not found" });
    }

    return res.json(updated);
  } catch (err: unknown) {
    if (err instanceof ZodError) {
      return res.status(400).json({
        error: "Validation error",
        details: err.issues.map((i) => ({
          path: i.path.join("."),
          message: i.message
        }))
      });
    }
    console.error(err);
    return res.status(500).json({ error: "Server error" });
  }
}
