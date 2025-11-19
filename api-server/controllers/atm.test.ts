import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import { NextFunction, Request, Response } from "express";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import * as messaging from "../messaging.js";

vi.mock("../db/queries");
vi.mock("../messaging");
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
    expect(messaging.sendToATM).toBeCalledWith(1, "withdraw", {
      amount: 100.5,
    });
    expect(messaging.waitForATM).toHaveBeenCalledWith(1, "withdraw-ready");
    expect(queries.updateLedgerForWithdrawal).toHaveBeenCalledWith(1, 100.5);
  });

  it("should return 404 if the ATM is not in use by the user", async () => {
    vi.mocked(queries.touchlessSessionExists).mockResolvedValue(false);

    const response = await request(app)
      .post("/touchless/1/withdraw")
      .send({ amount: 100.5 });

    expect(response.status).toBe(404);
    expect(queries.updateLedgerForWithdrawal).not.toBeCalled();
  });

  it("should return 400 if the ATM ID is invalid", async () => {
    const response = await request(app)
      .post("/touchless/123abc/withdraw")
      .send({ amount: 100.5 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).not.toBeCalled();
  });

  it("should return 400 if the amount is negative", async () => {
    const response = await request(app)
      .post("/touchless/1/withdraw")
      .send({ amount: -100.5 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).not.toBeCalled();
  });

  it("should return 400 if the amount is 0", async () => {
    const response = await request(app)
      .post("/touchless/1/withdraw")
      .send({ amount: 0 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).not.toBeCalled();
  });

  it("should return 400 if the amount is not a multiple of 0.01", async () => {
    const response = await request(app)
      .post("/touchless/1/withdraw")
      .send({ amount: 100.005 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).not.toBeCalled();
  });
});

describe("POST /touchless/:atmId/initate-deposit", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should initiate a cash deposit", async () => {
    vi.mocked(queries.touchlessSessionExists).mockResolvedValue(true);

    const response = await request(app).post("/touchless/1/initiate-deposit");

    expect(response.status).toBe(200);
    expect(messaging.sendToATM).toBeCalledWith(1, "initiate-deposit");
  });

  it("should return 400 if the ATM ID is invalid", async () => {
    const response = await request(app).post(
      "/touchless/123abc/initiate-deposit",
    );

    expect(response.status).toBe(400);
    expect(messaging.sendToATM).not.toBeCalled();
  });

  it("should return 404 if the ATM is not in use by the user", async () => {
    vi.mocked(queries.touchlessSessionExists).mockResolvedValue(false);

    const response = await request(app).post("/touchless/999/initiate-deposit");

    expect(response.status).toBe(404);
    expect(messaging.sendToATM).not.toBeCalled();
  });
});

describe("POST /touchless/:atmId/confirm-deposit", async () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should confirm a cash deposit", async () => {
    vi.mocked(queries.touchlessSessionExists).mockResolvedValue(true);
    vi.mocked(messaging.waitForATM).mockResolvedValue({ amount: 100 });

    const response = await request(app).post("/touchless/1/confirm-deposit");

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ amount: 100 });
    expect(messaging.sendToATM).toBeCalledWith(1, "confirm-deposit");
    expect(messaging.waitForATM).toBeCalledWith(1, "deposit-collected");
  });

  it("should return 400 if the ATM ID is invalid", async () => {
    const response = await request(app).post(
      "/touchless/123abc/confirm-deposit",
    );

    expect(response.status).toBe(400);
    expect(messaging.sendToATM).not.toBeCalled();
    expect(messaging.waitForATM).not.toBeCalled();
  });

  it("should return 404 if the ATM is not in use by the user", async () => {
    vi.mocked(queries.touchlessSessionExists).mockResolvedValue(false);

    const response = await request(app).post("/touchless/999/confirm-deposit");

    expect(response.status).toBe(404);
    expect(messaging.sendToATM).not.toBeCalled();
    expect(messaging.waitForATM).not.toBeCalled();
  });
});
