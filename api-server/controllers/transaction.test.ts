import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import { NextFunction, Request, Response } from "express";
import app from "../index.js";
import * as queries from "../db/queries/index.js";

vi.mock("../db/queries");
vi.mock("../middleware/auth", () => ({
  authenticate: (req: Request, _: Response, next: NextFunction) => {
    req.userId = 1;
    next();
  },
  requireVerified: (req: Request, _: Response, next: NextFunction) => {
    req.userVerified = true;
    next();
  },
}));

describe("POST /transfer", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should transfer money successfully", async () => {
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue({
      userId: 2,
      fullName: "Jane Doe",
      phoneNumber: "+651234567890",
      email: "jane@example.com",
      hashedPin: "123456",
      isInternal: false,
      phoneVerified: true,
      emailVerified: true,
    });
    vi.mocked(queries.transferMoney).mockResolvedValue(true);

    const response = await request(app).post("/transfer").send({
      recipient: "+651234567890",
      amount: 100.5,
    });

    expect(response.status).toBe(200);
    expect(queries.getUserByPhoneNumber).toHaveBeenCalledWith("+651234567890");
    expect(queries.transferMoney).toHaveBeenCalledWith(1, 2, 100.5);
  });

  it("should return 400 when recipient phone number is missing", async () => {
    const response = await request(app).post("/transfer").send({
      amount: 100.5,
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByPhoneNumber).not.toHaveBeenCalled();
    expect(queries.transferMoney).not.toHaveBeenCalled();
  });

  it("should return 400 when recipient phone number is not in E.164 format", async () => {
    const response = await request(app).post("/transfer").send({
      recipient: "1234567890",
      amount: 100.5,
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByPhoneNumber).not.toHaveBeenCalled();
    expect(queries.transferMoney).not.toHaveBeenCalled();
  });

  it("should return 400 when amount is missing", async () => {
    const response = await request(app).post("/transfer").send({
      recipient: "+651234567890",
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByPhoneNumber).not.toHaveBeenCalled();
    expect(queries.transferMoney).not.toHaveBeenCalled();
  });

  it("should return 400 when amount is negative", async () => {
    const response = await request(app).post("/transfer").send({
      recipient: "+651234567890",
      amount: -100.5,
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByPhoneNumber).not.toHaveBeenCalled();
    expect(queries.transferMoney).not.toHaveBeenCalled();
  });

  it("should return 400 when amount is 0", async () => {
    const response = await request(app).post("/transfer").send({
      recipient: "+651234567890",
      amount: 0,
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByPhoneNumber).not.toHaveBeenCalled();
    expect(queries.transferMoney).not.toHaveBeenCalled();
  });

  it("should return 400 when amount is not a multiple of 0.01", async () => {
    const response = await request(app).post("/transfer").send({
      recipient: "+651234567890",
      amount: 100.005,
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByPhoneNumber).not.toHaveBeenCalled();
    expect(queries.transferMoney).not.toHaveBeenCalled();
  });

  it("should return 400 when recipient does not exist", async () => {
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue(null);

    const response = await request(app).post("/transfer").send({
      recipient: "+651234567890",
      amount: 100.5,
    });

    expect(response.status).toBe(400);
    expect(response.body).toEqual({ error: "No existing user with specified phone number" });
    expect(queries.getUserByPhoneNumber).toHaveBeenCalledWith("+651234567890");
    expect(queries.transferMoney).not.toHaveBeenCalled();
  });

  it("should return 400 when sender has insufficient funds", async () => {
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue({
      userId: 2,
      fullName: "Jane Doe",
      phoneNumber: "+651234567890",
      email: "jane@example.com",
      hashedPin: "123456",
      isInternal: false,
      phoneVerified: true,
      emailVerified: true,
    });
    vi.mocked(queries.transferMoney).mockResolvedValue(false);

    const response = await request(app).post("/transfer").send({
      recipient: "+651234567890",
      amount: 100.5,
    });

    expect(response.status).toBe(400);
    expect(response.body).toEqual({ error: "Insufficient funds" });
    expect(queries.getUserByPhoneNumber).toHaveBeenCalledWith("+651234567890");
    expect(queries.transferMoney).toHaveBeenCalledWith(1, 2, 100.5);
  });
});

// 
vi.mock("../middleware/auth", () => ({
  authenticate: (req: Request, _: Response, next: NextFunction) => {
    req.userId = 1;
    next();
  },
}));

describe("GET /transaction-history", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should return results in descending timestamp order", async () => {
    vi.mocked(queries.getTransactionHistory).mockResolvedValue([
      {
        transactionId: 2,
        timestamp: new Date("2026-01-03T00:00:00.000Z"),
        description: "Deposit",
        myChange: "5.00",
        counterpartyUserId: 9,
        counterpartyName: "X",
        counterpartyIsInternal: true,
      },
      {
        transactionId: 1,
        timestamp: new Date("2026-01-01T00:00:00.000Z"),
        description: "NETS Payment",
        myChange: "-2.00",
        counterpartyUserId: 8,
        counterpartyName: "Y",
        counterpartyIsInternal: false,
      },
    ]);

    const res = await request(app).get("/transaction-history");

    expect(res.status).toBe(200);
    expect(res.body[0].transactionId).toBe(2);
    expect(res.body[1].transactionId).toBe(1);
  });

  it("should return an empty array if the user has no transactions", async () => {
    vi.mocked(queries.getTransactionHistory).mockResolvedValue([]);

    const res = await request(app).get("/transaction-history");

    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
    expect(queries.getTransactionHistory).toHaveBeenCalledWith(1);
  });
});
