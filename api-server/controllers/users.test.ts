import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import jwt from "jsonwebtoken";
import app from "../index.js";
import * as env from "../env.js";
import * as queries from "../db/queries/index.js";
import * as tokenService from "../utils/tokenService.js";

vi.mock("../db/queries");
vi.mock("../utils/tokenService");

// mock token service
vi.mock("../utils/tokenService", async (importOriginal) => {
  return {
    generateAuthTokens: vi.fn().mockImplementation((userId) => {
      const accessToken = jwt.sign({ userId }, env.JWT_SECRET || "test-secret", { expiresIn: "2m" });
      return Promise.resolve({
        accessToken,
        refreshToken: "mock-refresh-token-string",
      });
    }),
  };
});

describe("POST /auth/signup", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should create a new user with valid data", async () => {
    vi.mocked(queries.createUser).mockResolvedValue(true);

    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(201);
    expect(queries.createUser).toHaveBeenCalledWith({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      pin: "123456",
    });
  });

  it("should return 400 when fullName is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      phoneNumber: "+651234567890",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when fullName is empty", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when phoneNumber is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when phoneNumber is not in E.164 format", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when email is invalid", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "invalid-email@.com",
      pin: "123456",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when email is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      pin: "123456",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 409 when email is already in use", async () => {
    vi.mocked(queries.createUser).mockResolvedValue(false);
    vi.mocked(queries.createUser).mockResolvedValue(false);

    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(409);
  });

  it("should return 400 when pin is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when pin contains non-numeric characters", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      pin: "abc123",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when pin is not 6 digits", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      pin: "12345",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
    expect(queries.createUser).not.toHaveBeenCalled();
  });
});

describe("POST /auth/login", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should return an accessToken and refreshToken", async () => {
    vi.mocked(queries.getUserByCredentials).mockResolvedValue({
      userId: 1,
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      hashedPin: "123456",
      isInternal: false,
    });
    vi.mocked(tokenService.generateAuthTokens).mockResolvedValue({
      accessToken: "access-token",
      refreshToken: "refresh-token",
    });

    const response = await request(app).post("/auth/login").send({
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("accessToken");
    expect(response.body.accessToken).toBe("access-token");
    expect(response.body).toHaveProperty("refreshToken");
    expect(response.body.refreshToken).toBe("refresh-token");
    expect(tokenService.generateAuthTokens).toHaveBeenCalledWith(1);
  });

  it("should return 400 when user does not exist or wrong PIN", async () => {
    vi.mocked(queries.getUserByCredentials).mockResolvedValue(null);

    const response = await request(app).post("/auth/login").send({
      email: "nonexistent@example.com",
      pin: "123457",
    });

    expect(response.status).toBe(400);
    expect(tokenService.generateAuthTokens).not.toHaveBeenCalled();
  });

  it("should return 400 when email is invalid", async () => {
    const response = await request(app).post("/auth/login").send({
      email: "invalid-email@.com",
      pin: "123456",
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByCredentials).not.toHaveBeenCalled();
    expect(tokenService.generateAuthTokens).not.toHaveBeenCalled();
  });

  it("should return 400 when pin is invalid", async () => {
    const response = await request(app).post("/auth/login").send({
      email: "john@example.com",
      pin: "abc123",
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByCredentials).not.toHaveBeenCalled();
    expect(tokenService.generateAuthTokens).not.toHaveBeenCalled();
  });
});

// tests for refresh logic
describe("POST /auth/refresh", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should return 401 if no refresh token is provided", async () => {
    const response = await request(app).post("/auth/refresh").send({});
    expect(response.status).toBe(401);
    expect(response.body.error).toBe("No refresh token provided");
  });

  it("should return 401 if token is not found in DB or expired", async () => {
    vi.mocked(queries.getRefreshToken).mockResolvedValue(null as any);

    const response = await request(app).post("/auth/refresh").send({ refreshToken: "some-invalid-token" });
    const response = await request(app).post("/auth/refresh").send({ refreshToken: "some-invalid-token" });

    expect(response.status).toBe(401);
    expect(response.body.error).toBe("Invalid or expired refresh token");
  });

  it("should rotate tokens and return 200 on success", async () => {
    // find valid token
    const validStoredToken = {
      id: 123,
      userId: 1,
      token: "valid-old-token",
      expiresAt: new Date(Date.now() + 100000),
      createdAt: new Date(),
    };
    // mock the finding of the token
    vi.mocked(queries.getRefreshToken).mockResolvedValue(validStoredToken as any); // ts(2345) here

    vi.mocked(queries.getRefreshToken).mockResolvedValue(validStoredToken);
    vi.mocked(queries.deleteRefreshToken).mockResolvedValue(undefined);

    const response = await request(app).post("/auth/refresh").send({ refreshToken: "valid-old-token" });
    const response = await request(app).post("/auth/refresh").send({ refreshToken: "valid-old-token" });

    expect(response.status).toBe(200);

    // check if got new Access Token
    expect(response.body).toHaveProperty("accessToken");
    expect(queries.deleteRefreshToken).toHaveBeenCalledWith(123);
  });
});
