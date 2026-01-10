import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import type { NextFunction, Request, Response } from "express";
import app from "../index.js";
import * as queries from "../db/queries/index.js";

vi.mock("../db/queries");

let mockUserId: number | undefined = 1;

vi.mock("../middleware/auth", () => ({
  authenticate: (req: Request, _: Response, next: NextFunction) => {
    if (mockUserId !== undefined) req.userId = mockUserId;
    next();
  },
}));

describe("PUT /profile/update", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockUserId = 1; 
  });

  it("should return 401 if userId is missing", async () => {
    mockUserId = undefined;

    const res = await request(app).put("/profile/update").send({ fullName: "A" });

    expect(res.status).toBe(401);
    expect(res.body).toEqual({ error: "Unauthorized" });
    expect(queries.updateUserProfile).not.toHaveBeenCalled();
  });

  it("should return 400 if body is empty", async () => {
    const res = await request(app).put("/profile/update").send({});

    expect(res.status).toBe(400);
    expect(queries.updateUserProfile).not.toHaveBeenCalled();
  });

  it("should return 400 if phoneNumber is invalid", async () => {
    const res = await request(app).put("/profile/update").send({ phoneNumber: "123" });

    expect(res.status).toBe(400);
    expect(queries.updateUserProfile).not.toHaveBeenCalled();
  });

  it("should return 400 if body contains unknown fields", async () => {
    const res = await request(app).put("/profile/update").send({ hashedPin: "123456" });

    expect(res.status).toBe(400);
    expect(queries.updateUserProfile).not.toHaveBeenCalled();
  });

  it("should return 404 if user is not found", async () => {
    vi.mocked(queries.updateUserProfile).mockResolvedValue(null);

    const res = await request(app).put("/profile/update").send({ fullName: "New Name" });

    expect(res.status).toBe(404);
    expect(res.body).toEqual({ error: "User not found" });
    expect(queries.updateUserProfile).toHaveBeenCalledWith(1, { fullName: "New Name" });
  });

  it("should update profile successfully", async () => {
    vi.mocked(queries.updateUserProfile).mockResolvedValue({
      userId: 1,
      fullName: "New Name",
      phoneNumber: "91234567",
      email: "test@example.com",
    });

    const res = await request(app).put("/profile/update").send({ fullName: "New Name" });

    expect(res.status).toBe(200);
    expect(res.body).toEqual({
      userId: 1,
      fullName: "New Name",
      phoneNumber: "91234567",
      email: "test@example.com",
    });
    expect(queries.updateUserProfile).toHaveBeenCalledWith(1, { fullName: "New Name" });
  });

  it("should return 500 if the database throws", async () => {
    vi.mocked(queries.updateUserProfile).mockRejectedValue(new Error("DB down"));

    const res = await request(app).put("/profile/update").send({ fullName: "New Name" });

    expect(res.status).toBe(500);
  });
});

describe("GET /profile/get", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockUserId = 1; 
  });

  it("should return 401 if userId is missing", async () => {
    mockUserId = undefined;

    const res = await request(app).get("/profile/get");

    expect(res.status).toBe(401);
    expect(res.body).toEqual({ error: "Unauthorized" });
    expect(queries.getUserProfile).not.toHaveBeenCalled();
  });

  it("should return 404 if user not found", async () => {
    vi.mocked(queries.getUserProfile).mockResolvedValue(null);

    const res = await request(app).get("/profile/get");

    expect(res.status).toBe(404);
    expect(res.body).toEqual({ error: "User not found" });
    expect(queries.getUserProfile).toHaveBeenCalledWith(1);
  });

  it("should return user profile if found", async () => {
    vi.mocked(queries.getUserProfile).mockResolvedValue({
      fullName: "Test User",
      phoneNumber: "91234567",
      email: "test@example.com",
    });

    const res = await request(app).get("/profile/get");

    expect(res.status).toBe(200);
    expect(res.body).toEqual({
      fullName: "Test User",
      phoneNumber: "91234567",
      email: "test@example.com",
    });
    expect(queries.getUserProfile).toHaveBeenCalledWith(1);
  });

  it("should return 500 if DB throws error", async () => {
    vi.mocked(queries.getUserProfile).mockRejectedValue(new Error("DB down"));

    const res = await request(app).get("/profile/get");

    expect(res.status).toBe(500);
  });
});