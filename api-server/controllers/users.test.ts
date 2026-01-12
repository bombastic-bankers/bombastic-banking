import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import jwt from "jsonwebtoken";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import * as env from "../env.js";
import e from "express";

vi.mock("../db/queries");

async function createMockUser(overrides: Partial<any> = {}) {
  return {
    userId: 1,
    fullName: "John Doe",
    phoneNumber: "+651234567890",
    email: "john@example.com",
    hashedPin: "hashed_pin",
    ...overrides,
  };
}

describe("POST /auth/signup", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should create a new user with valid data", async () => {
    vi.mocked(queries.getEmailVerificationByEmail).mockResolvedValue({
      id: 1,
      email: "john@example.com",
      token: "token123",
      verifiedAt: new Date(),
      expiresAt: new Date(Date.now() + 100000),
      createdAt: new Date(),
    });

    vi.mocked(queries.getUserByEmail).mockResolvedValue(null);

    vi.mocked(queries.createUser).mockResolvedValue(true);

    vi.mocked(queries.deleteEmailToken).mockResolvedValue(undefined);

    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(201);
    expect(queries.createUser).toHaveBeenCalled();
    expect(queries.deleteEmailToken).toHaveBeenCalledWith(1);
  });

  it("should return 400 when fullName is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      phoneNumber: "+651234567890",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(400);
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
  });

  it("should return 400 when phoneNumber is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(400);
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
  });

  it("should return 400 when email is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      pin: "123456",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
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
    expect(response.body.error).toBe("Email already in use");
  });

  it("should return 400 when pin is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
    });

    expect(response.status).toBe(400);
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
  });
});

describe("POST /auth/login", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should return an auth token", async () => {
    vi.mocked(queries.getUserByCredentials).mockResolvedValue({
      userId: 1,
      fullName: "John Doe",
      phoneNumber: "+651234567890",
      email: "john@example.com",
      hashedPin: "hashed_pin",
    });

    const response = await request(app).post("/auth/login").send({
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("token");
    expect(response.body.token).toBeTypeOf("string");
    const payload = jwt.verify(
      response.body.token,
      env.JWT_SECRET
    ) as jwt.JwtPayload;
    expect(payload.userId).toBe(1);
  });

  it("should return 400 when credentials are incorrect", async () => {
    vi.mocked(queries.getUserByCredentials).mockResolvedValue(null);

    const response = await request(app).post("/auth/login").send({
      email: "nonexistent@example.com",
      pin: "123457",
    });

    expect(response.status).toBe(400);
  });

  it("should return 400 when email is invalid", async () => {
    const response = await request(app).post("/auth/login").send({
      email: "invalid-email@.com",
      pin: "123456",
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByCredentials).not.toHaveBeenCalled();
  });

  it("should return 400 when pin is invalid", async () => {
    const response = await request(app).post("/auth/login").send({
      email: "john@example.com",
      pin: "abc123",
    });

    expect(response.status).toBe(400);
    expect(queries.getUserByCredentials).not.toHaveBeenCalled();
  });
});
