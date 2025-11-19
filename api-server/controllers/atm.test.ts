import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import { NextFunction, Request, Response } from "express";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import * as pusher from "../pubsub.js";

vi.mock("../db/queries");
vi.mock("../pubsub");
vi.mock("../env", () => ({
  JWT_SECRET: "secret",
  DATABASE_URL: "postgresql://user:password@host.tld/dbname",
  PUSHER_APP_ID: "app-id",
  PUSHER_KEY: "key",
  PUSHER_SECRET: "secret",
  PUSHER_CLUSTER: "cluster",
  SERVER_SELF_AUTH_KEY: "server-key",
}));
vi.mock("../middleware/auth", () => ({
  authenticate: (req: Request, res: Response, next: NextFunction) => {
    req.userId = 1;
    next();
  },
}));

describe("POST /touchless/:atmId", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should start a touchless session", async () => {
    vi.mocked(queries.atmExists).mockResolvedValue(true);
    vi.mocked(queries.startTouchlessSession).mockResolvedValue(true);

    const response = await request(app).post("/touchless/1");

    expect(response.status).toBe(200);
    expect(queries.startTouchlessSession).toHaveBeenCalledWith(1, 1);
  });

  it("should return 400 if the ATM ID is invalid", async () => {
    const response = await request(app).post("/touchless/123abc");

    expect(response.status).toBe(400);
  });

  it("should return 404 if the ATM ID does not exist", async () => {
    vi.mocked(queries.atmExists).mockResolvedValue(false);

    const response = await request(app).post("/touchless/1");

    expect(response.status).toBe(404);
  });

  it("should return 409 if the ATM is already in use", async () => {
    vi.mocked(queries.atmExists).mockResolvedValue(true);
    vi.mocked(queries.startTouchlessSession).mockResolvedValue(false);

    const response = await request(app).post("/touchless/1");

    expect(response.status).toBe(409);
    expect(queries.startTouchlessSession).toHaveBeenCalledWith(1, 1);
  });
});

describe("DELETE /touchless/:atmId", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should end a touchless session", async () => {
    vi.mocked(queries.endTouchlessSession).mockResolvedValue(true);

    const response = await request(app).delete("/touchless/1");

    expect(response.status).toBe(200);
    expect(queries.endTouchlessSession).toHaveBeenCalledWith(1, 1);
  });

  it("should return 404 if the ATM is not in use by the user", async () => {
    vi.mocked(queries.endTouchlessSession).mockResolvedValue(false);

    const response = await request(app).delete("/touchless/1");

    expect(response.status).toBe(404);
    expect(queries.endTouchlessSession).toHaveBeenCalledWith(1, 1);
  });
});

describe("POST /touchless/:atmId/withdraw", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should withdraw cash", async () => {
    vi.mocked(queries.touchlessSessionExists).mockResolvedValue(true);

    const response = await request(app)
      .post("/touchless/1/withdraw")
      .send({ amount: 100.5 });

    expect(response.status).toBe(200);
    expect(pusher.sendToATM).toBeCalledWith(1, "withdraw", { amount: 100.5 });
    expect(pusher.waitForATM).toHaveBeenCalledWith(1, "withdraw-ready");
    expect(queries.updateLedgerForWithdrawal).toHaveBeenCalledWith(1, 100.5);
  });

  it("should return 404 if the ATM is not in use by the user", async () => {
    vi.mocked(queries.touchlessSessionExists).mockResolvedValue(false);

    const response = await request(app)
      .post("/touchless/1/withdraw")
      .send({ amount: 100.5 });

    expect(response.status).toBe(404);
    expect(queries.updateLedgerForWithdrawal).toBeCalledTimes(0);
  });

  it("should return 400 if the ATM ID is invalid", async () => {
    const response = await request(app)
      .post("/touchless/123abc/withdraw")
      .send({ amount: 100.5 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).toBeCalledTimes(0);
  });

  it("should return 400 if the amount is negative", async () => {
    const response = await request(app)
      .post("/touchless/1/withdraw")
      .send({ amount: -100.5 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).toBeCalledTimes(0);
  });

  it("should return 400 if the amount is 0", async () => {
    const response = await request(app)
      .post("/touchless/1/withdraw")
      .send({ amount: 0 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).toBeCalledTimes(0);
  });

  it("should return 400 if the amount is not a multiple of 0.01", async () => {
    const response = await request(app)
      .post("/touchless/1/withdraw")
      .send({ amount: 100.005 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).toBeCalledTimes(0);
  });
});
