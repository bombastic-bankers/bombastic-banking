import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import { sendVerificationEmail } from "./services/emailVerificationService.js";
import { generateEmailToken } from "./verify.js";
import { email } from "zod";

vi.mock("../db/queries");

process.env.MOCK_TWILIO_SMS = "true";
process.env.MOCK_EMAIL = "true";

async function createMockVerificationRecord(overrides: Partial<any> = {}) {
  return {
    id: 1,
    email: "john@example.com",
    token: "token123",
    expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24), // 24 hours from now
    verifiedAt: null,
    createdAt: new Date(),
    ...overrides,
  };
}

describe("POST /verify/phone/send", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should send OTP regardless of whether phone exists", async () => {
    const res = await request(app)
      .post("/verify/phone/send")
      .send({ phoneNumber: "+65123456789" });

    expect(res.status).toBe(200);
    expect(res.body.message).toContain("OTP");
  });
});

describe("POST /verify/phone/verify", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should verify OTP successfully in mock mode", async () => {
    const res = await request(app).post("/verify/phone/verify").send({
      phoneNumber: "+65123456789",
      otp: "123456",
    });

    expect(res.status).toBe(200);
    expect(res.body.verified).toBe(true);
  });
});

describe("GET /verify/email/confirm", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should verify email successfully and mark it as verified", async () => {
    vi.mocked(queries.getEmailVerificationByToken).mockResolvedValue(
      await createMockVerificationRecord()
    );

    const res = await request(app)
      .get("/verify/email/confirm")
      .query({ token: "valid-token" });

    expect(res.status).toBe(200);
    expect(res.text).toContain("Verification Successful");

    // expect(queries.deleteEmailToken).toHaveBeenCalledWith(1);
  });

  it("should reject expired token", async () => {
    vi.mocked(queries.getEmailVerificationByToken).mockResolvedValue(
      await createMockVerificationRecord({
        expiresAt: new Date(Date.now() - 1000),
      })
    );

    const res = await request(app)
      .get("/verify/email/confirm")
      .query({ token: "expired-token" });

    expect(res.status).toBe(400);
    expect(res.text).toContain("Expired");
  });

  it("should reject invalid token (no record found)", async () => {
    vi.mocked(queries.getEmailVerificationByToken).mockResolvedValue(null);

    const res = await request(app)
      .get("/verify/email/confirm")
      .query({ token: "invalid-token" });

    expect(res.status).toBe(400);
    expect(res.text).toContain("invalid");
  });
});

describe("Verification utilities", () => {
  it("should not send real email in mock mode", async () => {
    await expect(
      sendVerificationEmail("test@example.com", "token123")
    ).resolves.not.toThrow();
  });

  it("should generate email token and expiry", () => {
    const { token, expiry } = generateEmailToken();
    expect(token).toBeTypeOf("string");
    expect(expiry).toBeInstanceOf(Date);
  });
});
