import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import { NextFunction, Request, Response } from "express";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import * as realtime from "../realtime.js";

vi.mock("../db/queries");
vi.mock("../realtime");
vi.mock("../middleware/auth", () => ({
  authenticate: (req: Request, _: Response, next: NextFunction) => {
    req.userId = 1;
    next();
  },
}));

describe("POST /touchless/:atmId/withdraw", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should withdraw cash", async () => {
    vi.mocked(queries.ensureTouchlessSession).mockResolvedValue(true);

    const response = await request(app).post("/touchless/1/withdraw").send({ amount: 100.5 });

    expect(response.status).toBe(200);
    expect(realtime.sendToATM).toBeCalledWith(1, "withdraw", {
      amount: 100.5,
    });
    expect(realtime.waitForATM).toHaveBeenCalledWith(1, "withdraw-ready");
    expect(queries.updateLedgerForWithdrawal).toHaveBeenCalledWith(1, 100.5);
  });

  it("should return 409 if the ATM is in use by another user", async () => {
    vi.mocked(queries.ensureTouchlessSession).mockResolvedValue(false);

    const response = await request(app).post("/touchless/1/withdraw").send({ amount: 100.5 });

    expect(response.status).toBe(409);
    expect(queries.updateLedgerForWithdrawal).not.toBeCalled();
  });

  it("should return 400 if the ATM ID is invalid", async () => {
    const response = await request(app).post("/touchless/123abc/withdraw").send({ amount: 100.5 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).not.toBeCalled();
  });

  it("should return 400 if the amount is negative", async () => {
    vi.mocked(queries.ensureTouchlessSession).mockResolvedValue(true);

    const response = await request(app).post("/touchless/1/withdraw").send({ amount: -100.5 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).not.toBeCalled();
  });

  it("should return 400 if the amount is 0", async () => {
    vi.mocked(queries.ensureTouchlessSession).mockResolvedValue(true);

    const response = await request(app).post("/touchless/1/withdraw").send({ amount: 0 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).not.toBeCalled();
  });

  it("should return 400 if the amount is not a multiple of 0.01", async () => {
    vi.mocked(queries.ensureTouchlessSession).mockResolvedValue(true);

    const response = await request(app).post("/touchless/1/withdraw").send({ amount: 100.005 });

    expect(response.status).toBe(400);
    expect(queries.updateLedgerForWithdrawal).not.toBeCalled();
  });
});

describe("POST /touchless/:atmId/deposit/start", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should initiate a cash deposit", async () => {
    vi.mocked(queries.ensureTouchlessSession).mockResolvedValue(true);

    const response = await request(app).post("/touchless/1/deposit/start");

    expect(response.status).toBe(200);
    expect(realtime.sendToATM).toBeCalledWith(1, "deposit-start");
  });

  it("should return 400 if the ATM ID is invalid", async () => {
    const response = await request(app).post("/touchless/123abc/deposit/start");

    expect(response.status).toBe(400);
    expect(realtime.sendToATM).not.toBeCalled();
  });

  it("should return 409 if the ATM is in use by another user", async () => {
    vi.mocked(queries.ensureTouchlessSession).mockResolvedValue(false);

    const response = await request(app).post("/touchless/999/deposit/start");

    expect(response.status).toBe(409);
    expect(realtime.sendToATM).not.toBeCalled();
  });
});

describe("POST /touchless/:atmId/deposit/count", async () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should count the deposited cash", async () => {
    vi.mocked(queries.ensureTouchlessSession).mockResolvedValue(true);
    vi.mocked(realtime.waitForATM).mockResolvedValue({ amount: 150.75 });

    const response = await request(app).post("/touchless/1/deposit/count");

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ amount: 150.75 });
    expect(realtime.sendToATM).toBeCalledWith(1, "deposit-count");
    expect(realtime.waitForATM).toHaveBeenCalledWith(1, "deposit-review");
  });

  it("should return 400 if the ATM ID is invalid", async () => {
    const response = await request(app).post("/touchless/123abc/deposit/count");

    expect(response.status).toBe(400);
    expect(realtime.sendToATM).not.toBeCalled();
    expect(realtime.waitForATM).not.toBeCalled();
  });

  it("should return 409 if the ATM is in use by another user", async () => {
    vi.mocked(queries.ensureTouchlessSession).mockResolvedValue(false);

    const response = await request(app).post("/touchless/999/deposit/count");

    expect(response.status).toBe(409);
    expect(realtime.sendToATM).not.toBeCalled();
    expect(realtime.waitForATM).not.toBeCalled();
  });
});

describe("POST /touchless/:atmId/deposit/confirm", async () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should confirm a cash deposit", async () => {
    vi.mocked(queries.atmExists).mockResolvedValue(true);
    vi.mocked(queries.ensureTouchlessSession).mockResolvedValue(true);
    vi.mocked(realtime.waitForATM).mockResolvedValue({ amount: 100 });

    const response = await request(app).post("/touchless/1/deposit/confirm");

    expect(response.status).toBe(200);
    expect(realtime.sendToATM).toBeCalledWith(1, "deposit-confirm");
  });

  it("should return 400 if the ATM ID is invalid", async () => {
    const response = await request(app).post("/touchless/123abc/deposit/confirm");

    expect(response.status).toBe(400);
    expect(realtime.sendToATM).not.toBeCalled();
    expect(realtime.waitForATM).not.toBeCalled();
  });

  it("should return 409 if the ATM is in use by another user", async () => {
    vi.mocked(queries.atmExists).mockResolvedValue(true);
    vi.mocked(queries.ensureTouchlessSession).mockResolvedValue(false);

    const response = await request(app).post("/touchless/999/deposit/confirm");

    expect(response.status).toBe(409);
    expect(realtime.sendToATM).not.toBeCalled();
    expect(realtime.waitForATM).not.toBeCalled();
  });
});

describe("POST /touchless/:atmId/exit", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should end the touchless session", async () => {
    vi.mocked(queries.endTouchlessSession).mockResolvedValue(true);

    const response = await request(app).post("/touchless/1/exit");

    expect(response.status).toBe(200);
    expect(queries.endTouchlessSession).toHaveBeenCalledWith(1, 1);
  });

  it("should return 404 if the ATM is not in use by the user", async () => {
    vi.mocked(queries.endTouchlessSession).mockResolvedValue(false);

    const response = await request(app).post("/touchless/1/exit");

    expect(response.status).toBe(404);
    expect(queries.endTouchlessSession).toHaveBeenCalledWith(1, 1);
  });
});
