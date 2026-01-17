import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import { sendVerificationEmail } from "./services/emailVerificationService.js";
import { generateEmailToken } from "./verify.js";
import { autoSendOTP } from "./services/smsVerificationService.js";
import { email } from "zod";
vi.mock("../db/queries");

vi.mock('twilio', () => {
  return {
    default: vi.fn(() => ({
      verify: {
        v2: {
          services: vi.fn(() => ({
            verifications: {
              create: vi.fn().mockResolvedValue({ status: 'pending' }),
            },
            verificationChecks: {
              create: vi.fn().mockResolvedValue({ status: 'approved' }),
            },
          })),
        },
      },
    })),
  };
});

vi.mock('@sendgrid/mail', () => ({
  default: {
    setApiKey: vi.fn(),
    send: vi.fn().mockResolvedValue([{ statusCode: 202 }, {}]),
  },
}));

async function createMockUser(overrides: Partial<any>= {}) {
  return {
    userId: 1,
    fullName: "John Doe",
    phoneNumber: "+651234567890",
    email: "john@example.com",
    pin: "123456",
    hashedPin: "hashed_pin",
    emailverified: true,
    phoneverified: true,
    emailToken:"token123",
    emailTokenExpiry: new Date(Date.now() + 1000 * 60 * 60 * 24),
    ...overrides,
  };
}

// send OTP
describe("POST /verify/phone/send", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should send OTP if phone exists", async () => {
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue(await createMockUser());

    const res = await request(app)
      .post("/verify/phone/send")
      .send({ phoneNumber: "+65123456789" });

    expect(res.status).toBe(200);
    expect(res.body.message).toContain("OTP");
    expect(queries.getUserByPhoneNumber).toHaveBeenCalled();
  });

  it("should return 404 if phone does not exist", async () => {
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue(null);

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
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue(await createMockUser());

    vi.mocked(queries.updatePhoneVerified).mockResolvedValue();

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
    vi.mocked(queries.getUserByPhoneNumber).mockResolvedValue(null);

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
    vi.mocked(queries.getUserByEmailToken).mockResolvedValue( await createMockUser({emailverified: false,}));

    vi.mocked(queries.verifyUserEmail).mockResolvedValue();

    const res = await request(app)
      .get("/verify/email/confirm")
      .query({ token: "valid-token" });

    expect(res.status).toBe(200);
    expect(res.text).toContain("Verification Successful");
  });

  it("should reject expired token", async () => {
    vi.mocked(queries.getUserByEmailToken).mockResolvedValue(await createMockUser({emailverified: false, emailTokenExpiry: new Date(Date.now() - 1000),}));

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
