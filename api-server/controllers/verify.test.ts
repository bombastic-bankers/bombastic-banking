import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import * as smsService from "../services/smsVerificationService.js";
import * as emailService from "../services/emailVerificationService.js";

vi.mock("../db/queries");

vi.mock("../services/emailVerificationService.js", () => ({
  sendVerificationEmail: vi.fn().mockResolvedValue(undefined),
  VerifyEmailLink: vi.fn().mockResolvedValue(true),
}));

vi.mock("../services/smsVerificationService.js", () => ({
  sendOTP: vi.fn().mockResolvedValue({ status: "pending" }),
  checkOTP: vi.fn().mockResolvedValue(true),
}));

async function createMockUser(overrides: Partial<any> = {}) {
  return {
    userId: 1,
    fullName: "John Doe",
    phoneNumber: "+651234567890",
    email: "john@example.com",
    hashedPin: "hashed_pin",
    phoneVerified: true,
    emailVerified: true,
    emailToken: null,
    emailTokenExpiry: null,
    isInternal: false,
    ...overrides,
  };
}

describe("Phone Verification", () => {
  beforeEach(() => vi.clearAllMocks());

  it("POST /send/phone should return 200 if phone exists", async () => {
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue(
      await createMockUser(),
    );

    const res = await request(app)
      .post("/send/phone")
      .send({ phoneNumber: "+651234567890" });

    expect(res.status).toBe(200);
    expect(smsService.sendOTP).toHaveBeenCalled();
  });

  it("GET /verify/phone should return 200 and verified true", async () => {
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue(
      await createMockUser(),
    );

    const res = await request(app)
      .post("/verify/phone")
      .send({ phoneNumber: "+651234567890", otp: "123456" });

    expect(res.status).toBe(200);
    expect(res.body.verified).toBe(true);
  });
});

describe("GET /verify/email/confirm", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should verify email successfully", async () => {
    vi.mocked(queries.getUserByEmailToken).mockResolvedValue(
      await createMockUser({
        emailVerified: false,
        emailTokenExpiry: new Date(Date.now() + 60_000), // still valid
      }),
    );

    vi.mocked(queries.verifyUserEmail).mockResolvedValue(undefined);

    const res = await request(app)
      .get("/verify/email/confirm")
      .query({ token: "valid-token" });

    expect(res.status).toBe(200);
    expect(res.text).toContain("Verification Successful");
    expect(queries.verifyUserEmail).toHaveBeenCalled();
  });

  it("should reject expired token", async () => {
    vi.mocked(queries.getUserByEmailToken).mockResolvedValue(
      await createMockUser({
        emailVerified: false,
        emailTokenExpiry: new Date(Date.now() - 1000), // expired
      }),
    );

    const res = await request(app)
      .get("/verify/email/confirm")
      .query({ token: "expired-token" });

    expect(res.status).toBe(400);
    expect(res.text).toContain("Expired");
  });

  it("should reject invalid token", async () => {
    vi.mocked(queries.getUserByEmailToken).mockResolvedValue(null);

    const res = await request(app)
      .get("/verify/email/confirm")
      .query({ token: "invalid-token" });

    expect(res.status).toBe(400);
    expect(res.text).toContain("Invalid");
  });
});
