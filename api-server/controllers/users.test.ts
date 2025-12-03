import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import jwt from "jsonwebtoken";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import * as env from "../env.js";

vi.mock("../db/queries");

async function createMockUser() {
  return {
    userId: 1,
    fullName: "John Doe",
    phoneNumber: "1234567890",
    email: "john@example.com",
    pin: "123456",
  };
}

describe("POST /auth/signup", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should create a new user with valid data", async () => {
    vi.mocked(queries.createUser).mockResolvedValue(true);

    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      email: "john@example.com",
      pin: "123456",
    });

    expect(response.status).toBe(201);
    expect(queries.createUser).toHaveBeenCalledWith({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      email: "john@example.com",
      pin: "123456",
    });
  });

  it("should return 400 when fullName is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      phoneNumber: "1234567890",
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

  it("should return 400 when email is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      pin: "123456",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when pin is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      email: "john@example.com",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when pin contains non-numeric characters", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      email: "john@example.com",
      pin: "abc123",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when pin is not 6 digits", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      email: "john@example.com",
      pin: "12345",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 409 when email is already in use", async () => {
    vi.mocked(queries.createUser).mockResolvedValue(false);

    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
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

  it("should return an auth token", async () => {
    vi.mocked(queries.getUserByCredentials).mockResolvedValue({
      userId: 1,
      fullName: "John Doe",
      phoneNumber: "1234567890",
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
    const payload = jwt.verify(response.body.token, env.JWT_SECRET) as jwt.JwtPayload;
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
});
