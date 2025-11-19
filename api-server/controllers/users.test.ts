import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import app from "..";
import * as queries from "../db/queries/index.js";
import * as env from "../env.js";

vi.mock("../db/queries");
vi.mock("../env", () => ({
  JWT_SECRET: "secret",
  DATABASE_URL: "postgresql://user:password@host.tld/dbname",
  PUSHER_APP_ID: "app-id",
  PUSHER_KEY: "key",
  PUSHER_SECRET: "secret",
  PUSHER_CLUSTER: "cluster",
  SERVER_SELF_AUTH_KEY: "server-key",
}));

async function createMockUser() {
  return {
    userId: 1,
    fullName: "John Doe",
    phoneNumber: "1234567890",
    email: "john@example.com",
    hashedPassword: await bcrypt.hash("password123", 10),
  };
}

describe("POST /auth/signup", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should create a new user with valid data", async () => {
    const mockUser = await createMockUser();
    vi.mocked(queries.createUser).mockResolvedValue(mockUser);

    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      email: "john@example.com",
      password: "password123",
    });

    expect(response.status).toBe(201);
    expect(response.body).toEqual(mockUser);
    expect(queries.createUser).toHaveBeenCalledWith({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      email: "john@example.com",
      hashedPassword: expect.any(String),
    });
  });

  it("should return 400 when fullName is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      phoneNumber: "1234567890",
      email: "john@example.com",
      password: "password123",
    });

    expect(response.status).toBe(400);
    expect(response.body).toEqual({ error: "Missing fields" });
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when phoneNumber is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      email: "john@example.com",
      password: "password123",
    });

    expect(response.status).toBe(400);
    expect(response.body).toEqual({ error: "Missing fields" });
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when email is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      password: "password123",
    });

    expect(response.status).toBe(400);
    expect(response.body).toEqual({ error: "Missing fields" });
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when password is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      email: "john@example.com",
    });

    expect(response.status).toBe(400);
    expect(response.body).toEqual({ error: "Missing fields" });
    expect(queries.createUser).not.toHaveBeenCalled();
  });
});

describe("POST /auth/login", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should return an auth token", async () => {
    const mockUser = await createMockUser();
    vi.mocked(queries.getUserByEmail).mockResolvedValue(mockUser);

    const response = await request(app).post("/auth/login").send({
      email: "john@example.com",
      password: "password123",
    });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("token");
    expect(response.body.token).toBeTypeOf("string");
    const decoded = jwt.verify(
      response.body.token,
      env.JWT_SECRET,
    ) as jwt.JwtPayload;
    expect(decoded.userId).toBe(1);
  });

  it("should return 400 when user does not exist", async () => {
    vi.mocked(queries.getUserByEmail).mockResolvedValue(null);

    const response = await request(app).post("/auth/login").send({
      email: "nonexistent@example.com",
      password: "password123",
    });

    expect(response.status).toBe(400);
    expect(response.body).toEqual({ error: "Incorrect email or password" });
  });

  it("should return 400 when password is incorrect", async () => {
    const mockUser = await createMockUser();
    vi.mocked(queries.getUserByEmail).mockResolvedValue(mockUser);

    const response = await request(app).post("/auth/login").send({
      email: "john@example.com",
      password: "wrong_password",
    });

    expect(response.status).toBe(400);
    expect(response.body).toEqual({ error: "Incorrect email or password" });
  });
});
