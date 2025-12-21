import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import * as auth from "../services/auth.js";
import { NextFunction, Request, Response } from "express";

vi.mock("../db/queries");
vi.mock("../services/auth");
vi.mock("../middleware/auth", () => ({
  authenticate: (req: Request, _: Response, next: NextFunction) => {
    req.userId = 1;
    next();
  },
}));
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
    phoneNumber: "+6512345678",
    email: "john@example.com",
    hashedPin: "hashed_pin",
    isInternal: false,
    phoneVerified: true,
    emailVerified: true,
    emailToken: null,
    emailTokenExpiry: null,
    ...overrides,
  };
}

describe("POST /auth/signup", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should return 201 when signup is successful", async () => {
    vi.mocked(queries.getUserByEmail).mockResolvedValue(null);
    vi.mocked(queries.createUser).mockResolvedValue(true);

    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(500);
    expect(queries.createUser).toHaveBeenCalledWith(
      expect.objectContaining({
        fullName: "John Doe",
        email: "john@example.com",
      }),
    );
  });

  it("should return 409 when email is already in use", async () => {
    vi.mocked(queries.getUserByEmail).mockResolvedValue(await createMockUser());

    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(409);
  });
});

describe("POST /auth/login", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should return an accessToken and refreshToken", async () => {
    vi.mocked(queries.getUserByCredentials).mockResolvedValue(await createMockUser());
    vi.mocked(auth.generateAccessToken).mockReturnValue("access-token");
    vi.mocked(auth.generateRefreshToken).mockReturnValue("refresh-token");

    const response = await request(app).post("/auth/login").send({
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("accessToken");
    expect(response.body).toHaveProperty("refreshToken");
  });

  it("should return 400 when email is invalid", async () => {
    const response = await request(app).post("/auth/login").send({
      email: "invalid-email@.com",
      pin: "123456",
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByCredentials).not.toHaveBeenCalled();
    expect(auth.generateAccessToken).not.toHaveBeenCalled();
  });

  it("should return 400 when pin is invalid", async () => {
    const response = await request(app).post("/auth/login").send({
      email: "john@example.com",
      pin: "abc123",
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByCredentials).not.toHaveBeenCalled();
    expect(auth.generateAccessToken).not.toHaveBeenCalled();
  });

  it("should return 401 when user does not exist or wrong PIN", async () => {
    vi.mocked(queries.getUserByCredentials).mockResolvedValue(null);

    const response = await request(app).post("/auth/login").send({
      email: "nonexistent@example.com",
      pin: "123457",
    });

    expect(response.status).toBe(401);
    expect(auth.generateAccessToken).not.toHaveBeenCalled();
  });
});

describe("POST /auth/refresh", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should return 400 if no refresh token is provided in body", async () => {
    const response = await request(app).post("/auth/refresh").send({});

    expect(response.status).toBe(400);
    expect(auth.generateAccessToken).not.toHaveBeenCalled();
    expect(queries.resetRefreshToken).not.toHaveBeenCalled();
  });

  it("should return 401 if refresh token is non-existent or expired", async () => {
    vi.mocked(queries.resetRefreshToken).mockResolvedValue(null);

    const response = await request(app).post("/auth/refresh").send({ refreshToken: "some-invalid-token" });

    expect(response.status).toBe(401);
    expect(queries.resetRefreshToken).toHaveBeenCalled();
  });

  it("should rotate tokens and return 200 on success", async () => {
    vi.mocked(queries.resetRefreshToken).mockResolvedValue(1);
    vi.mocked(auth.generateAccessToken).mockReturnValue("new-access-token");
    vi.mocked(auth.generateRefreshToken).mockReturnValue("new-refresh-token");

    const response = await request(app).post("/auth/refresh").send({ refreshToken: "valid-old-token" });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      accessToken: "new-access-token",
      refreshToken: "new-refresh-token",
    });
    expect(queries.resetRefreshToken).toHaveBeenCalledWith("valid-old-token", "new-refresh-token", expect.any(Date));
    expect(auth.generateAccessToken).toHaveBeenCalledWith(1);
    expect(auth.generateRefreshToken).toHaveBeenCalled();
  });
});

describe("PATCH /profile", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should update profile successfully", async () => {
    vi.mocked(queries.updateUserProfile).mockResolvedValue({
      userId: 1,
      fullName: "New Name",
      phoneNumber: "+6591234567",
      email: "test@example.com",
    });

    const res = await request(app).patch("/profile").send({ fullName: "New Name" });

    expect(res.status).toBe(200);
    expect(queries.updateUserProfile).toHaveBeenCalledWith(1, {
      fullName: "New Name",
    });
  });
});

describe("GET /profile", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should return user profile if found", async () => {
    vi.mocked(queries.getUserProfile).mockResolvedValue({
      fullName: "Test User",
      phoneNumber: "+6581234567",
      email: "test@example.com",
    });

    const res = await request(app).get("/profile");
    expect(res.status).toBe(200);
    expect(res.body.fullName).toBe("Test User");
    expect(queries.getUserProfile).toHaveBeenCalledWith(1);
  });
});
