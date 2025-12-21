import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import {
  sendVerificationEmail,
  generateEmailToken,
  autoSendOTP,
} from "./verify.js";

vi.mock("../db/queries");

process.env.MOCK_TWILIO_SMS = "true";
process.env.MOCK_EMAIL = "true";

// send OTP
describe("POST /verify/phone/send", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should send OTP if phone exists", async () => {
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue({
      userId: 1,
      phoneNumber: "+65123456789",
    } as any);

    const res = await request(app)
      .post("/verify/phone/send")
      .send({ phoneNumber: "+65123456789" });

    expect(res.status).toBe(200);
    expect(res.body.message).toContain("OTP");
    expect(queries.getUserByPhoneNumber).toHaveBeenCalled();
  });

  it("should return 404 if phone does not exist", async () => {
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue(null as any);

    const res = await request(app)
      .post("/verify/phone/send")
      .send({ phoneNumber: "+65111111111" });

    expect(res.status).toBe(404);
  });
});

// verify OTP
describe("POST /verify/phone/verify", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should verify OTP successfully", async () => {
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue({
      userId: 1,
    } as any);

    vi.mocked(queries.updatePhoneVerified).mockResolvedValue(true as any);

    const res = await request(app)
      .post("/verify/phone/verify")
      .send({
        phoneNumber: "+65123456789",
        otp: "123456",
      });

    expect(res.status).toBe(200);
    expect(res.body.verified).toBe(true);
    expect(queries.updatePhoneVerified).toHaveBeenCalledWith(1, true);
  });

  it("should return 404 if phone not registered", async () => {
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue(null as any);

    const res = await request(app)
      .post("/verify/phone/verify")
      .send({
        phoneNumber: "+65123456789",
        otp: "123456",
      });

    expect(res.status).toBe(404);
  });

  it("should return 400 if OTP format is invalid", async () => {
    const res = await request(app)
      .post("/verify/phone/verify")
      .send({
        phoneNumber: "+65123456789",
        otp: "12",
      });

    expect(res.status).toBe(400);
  });
});

// email verification
describe("GET /verify/email/confirm", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should verify email successfully", async () => {
    vi.mocked(queries.getUserByEmailToken).mockResolvedValue({
      userId: 1,
      emailverified: false,
      emailTokenExpiry: new Date(Date.now() + 10000),
    } as any);

    vi.mocked(queries.verifyUserEmail).mockResolvedValue(true as any);

    const res = await request(app)
      .get("/verify/email/confirm")
      .query({ token: "valid-token" });

    expect(res.status).toBe(200);
    expect(res.text).toContain("Verification Successful");
  });

  it("should reject expired token", async () => {
    vi.mocked(queries.getUserByEmailToken).mockResolvedValue({
      userId: 1,
      emailverified: false,
      emailTokenExpiry: new Date(Date.now() - 1000),
    } as any);

    const res = await request(app)
      .get("/verify/email/confirm")
      .query({ token: "expired-token" });

    expect(res.status).toBe(400);
    expect(res.text).toContain("Expired");
  });

  it("should reject invalid token", async () => {
    vi.mocked(queries.getUserByEmailToken).mockResolvedValue(null as any);

    const res = await request(app)
      .get("/verify/email/confirm")
      .query({ token: "invalid-token" });

    expect(res.status).toBe(400);
  });
});

// verification utilities
describe("Verification utilities", () => {
  it("should not send real email in mock mode", async () => {
    await expect(
      sendVerificationEmail("test@example.com", "token123")
    ).resolves.not.toThrow();
  });

  it("should generate email token and expiry", () => {
    const { token, expiry } = generateEmailToken();

    expect(token).toBeTypeOf("string");
    expect(token.length).toBeGreaterThan(10);
    expect(expiry).toBeInstanceOf(Date);
  });

  it("should not throw when auto sending OTP in mock mode", async () => {
    await expect(autoSendOTP("+65123456789")).resolves.not.toThrow();
  });
});
