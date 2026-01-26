import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import * as smsService from "../services/smsVerificationService.js";
import * as emailService from "../services/emailVerificationService.js";

vi.mock("../db/queries");

vi.mock("../services/emailVerificationService.js", () => ({
  sendVerificationEmail: vi.fn().mockResolvedValue(undefined),
  checkEmailOTP: vi.fn().mockResolvedValue(true),
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

describe("Email Verification", () => {
  beforeEach(() => vi.clearAllMocks());

  it("GET /verify/email should return 200 for correct code", async () => {
    vi.mocked(queries.getUserByEmail).mockResolvedValue(
      await createMockUser({ emailVerified: false }),
    );

    const res = await request(app)
      .post("/verify/email")
      .send({ email: "john@example.com", token: "123456" });

    expect(res.status).toBe(200);
    expect(res.body.verified).toBe(true);
    expect(queries.verifyUserEmail).toHaveBeenCalled();
  });

  it("GET /verify/email should return 400 for incorrect code", async () => {
    vi.mocked(queries.getUserByEmail).mockResolvedValue(await createMockUser());
    vi.mocked(emailService.checkEmailOTP).mockResolvedValueOnce(false);

    const res = await request(app)
      .get("/verify/email")
      .send({ email: "john@example.com", token: "000000" });

    expect(res.status).toBe(400);
    expect(res.body.verified).toBe(false);
  });
});