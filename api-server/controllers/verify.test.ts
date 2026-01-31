import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import * as smsService from "../services/smsVerificationService.js";
import * as emailService from "../services/emailVerificationService.js";
import * as realtime from "../services/realtime.js";
import { NextFunction, Request, Response } from "express";

vi.mock("../db/queries");
vi.mock("../services/smsVerificationService.js");
vi.mock("../services/emailVerificationService.js");
vi.mock("../services/realtime.js");
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

function createMockUser(overrides: Partial<any> = {}) {
  return {
    userId: 1,
    fullName: "John Doe",
    phoneNumber: "+651234567890",
    email: "john@example.com",
    hashedPin: "hashed_pin",
    phoneVerified: false,
    emailVerified: false,
    isInternal: false,
    ...overrides,
  };
}

describe("POST /verification/sms", () => {
  beforeEach(() => vi.clearAllMocks());

  it("should send SMS to authenticated user's phone", async () => {
    vi.mocked(queries.getUserById).mockResolvedValue(createMockUser());

    const res = await request(app).post("/verification/sms");

    expect(res.status).toBe(200);
    expect(smsService.sendOTP).toHaveBeenCalledWith("+651234567890");
  });

  it("should return 404 if user not found", async () => {
    vi.mocked(queries.getUserById).mockResolvedValue(null);

    const res = await request(app).post("/verification/sms");

    expect(res.status).toBe(404);
    expect(smsService.sendOTP).not.toHaveBeenCalled();
  });
});

describe("POST /verification/email", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(emailService.generateEmailToken).mockReturnValue({
      token: "mock-token",
      expiry: new Date(),
    });
  });

  it("should send email to authenticated user's email", async () => {
    vi.mocked(queries.getUserById).mockResolvedValue(createMockUser());

    const res = await request(app).post("/verification/email");

    expect(res.status).toBe(200);
    expect(emailService.generateEmailToken).toHaveBeenCalled();
    expect(emailService.sendVerificationEmail).toHaveBeenCalledWith("john@example.com", "mock-token");
    expect(queries.saveEmailToken).toHaveBeenCalledWith(1, "mock-token", expect.any(Date));
  });

  it("should return 404 if user not found", async () => {
    vi.mocked(queries.getUserById).mockResolvedValue(null);

    const res = await request(app).post("/verification/email");

    expect(res.status).toBe(404);
    expect(emailService.generateEmailToken).not.toHaveBeenCalled();
  });
});

describe("POST /verification/sms/confirm", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(smsService.checkOTP).mockResolvedValue(true);
  });

  it("should verify OTP for authenticated user", async () => {
    vi.mocked(queries.getUserById).mockResolvedValue(createMockUser());

    const res = await request(app).post("/verification/sms/confirm").send({ otp: "123456" });

    expect(res.status).toBe(200);
    expect(queries.updatePhoneVerified).toHaveBeenCalledWith(1, true);
  });

  it("should return 404 if user not found", async () => {
    vi.mocked(queries.getUserById).mockResolvedValue(null);

    const res = await request(app).post("/verification/sms/confirm").send({ otp: "123456" });

    expect(res.status).toBe(404);
    expect(queries.updatePhoneVerified).not.toHaveBeenCalled();
  });

  it("should return 400 when OTP is invalid", async () => {
    vi.mocked(queries.getUserById).mockResolvedValue(createMockUser());
    vi.mocked(smsService.checkOTP).mockResolvedValue(false);

    const res = await request(app).post("/verification/sms/confirm").send({ otp: "123456" });

    expect(res.status).toBe(400);
    expect(queries.updatePhoneVerified).not.toHaveBeenCalled();
  });

  it("should return 400 if OTP is missing", async () => {
    const res = await request(app).post("/verification/sms/confirm").send({});

    expect(res.status).toBe(400);
    expect(queries.getUserById).not.toHaveBeenCalled();
  });
});

describe("GET /verification/email/confirm", () => {
  beforeEach(() => vi.clearAllMocks());

  it("should verify email successfully", async () => {
    vi.mocked(queries.verifyUserEmailByToken).mockResolvedValue({
      userId: 1,
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      hashedPin: "hashed_pin",
      phoneVerified: true,
      emailVerified: false,
      isInternal: false,
      emailTokenExpiry: new Date(Date.now() + 60_000),
    });

    const res = await request(app).get("/verification/email/confirm").query({ token: "valid-token" });

    expect(res.status).toBe(200);
  });

  it("should reject expired token", async () => {
    vi.mocked(queries.verifyUserEmailByToken).mockResolvedValue({
      userId: 1,
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      hashedPin: "hashed_pin",
      phoneVerified: true,
      emailVerified: false,
      isInternal: false,
      emailTokenExpiry: new Date(Date.now() - 1000),
    });

    const res = await request(app).get("/verification/email/confirm").query({ token: "expired-token" });

    expect(res.status).toBe(400);
  });

  it("should reject invalid token", async () => {
    vi.mocked(queries.verifyUserEmailByToken).mockResolvedValue(null);

    const res = await request(app).get("/verification/email/confirm").query({ token: "invalid-token" });

    expect(res.status).toBe(400);
  });

  it("should return 200 if email already verified", async () => {
    vi.mocked(queries.verifyUserEmailByToken).mockResolvedValue({
      userId: 1,
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      hashedPin: "hashed_pin",
      phoneVerified: true,
      emailVerified: true,
      isInternal: false,
      emailTokenExpiry: new Date(Date.now() + 60_000),
    });

    const res = await request(app).get("/verification/email/confirm").query({ token: "valid-token" });

    expect(res.status).toBe(200);
  });

  it("should return 400 if token is missing", async () => {
    const res = await request(app).get("/verification/email/confirm").query({});

    expect(res.status).toBe(400);
    expect(queries.verifyUserEmailByToken).not.toHaveBeenCalled();
  });
});

describe("GET /verification/email/wait", () => {
  beforeEach(() => vi.clearAllMocks());

  it("should return immediately if already verified", async () => {
    vi.mocked(queries.getUserById).mockResolvedValue(createMockUser({ emailVerified: true }));
    vi.mocked(realtime.waitForEmailVerification).mockResolvedValue(undefined);

    const res = await request(app).get("/verification/email/wait");

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ verified: true });
  });

  it("should return 404 if user not found", async () => {
    vi.mocked(queries.getUserById).mockResolvedValue(null);
    vi.mocked(realtime.waitForEmailVerification).mockResolvedValue(undefined);

    const res = await request(app).get("/verification/email/wait");

    expect(res.status).toBe(404);
  });

  it("should timeout if verification doesn't happen", async () => {
    vi.mocked(queries.getUserById).mockResolvedValue(createMockUser({ emailVerified: false }));
    vi.mocked(realtime.waitForEmailVerification).mockRejectedValue(new Error("Verification timeout"));

    const res = await request(app).get("/verification/email/wait");

    expect(res.status).toBe(408);
    expect(res.body).toEqual({ error: "Verification timeout" });
  });
});
