import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import app from "../index.js";
import * as queries from "../db/queries/index.js";
import * as env from "../env.js";
import { generateAuthTokens } from "../utils/tokenService.js";

vi.mock("../db/queries");

// mock token service
vi.mock("../utils/tokenService", async (importOriginal) => {
  return {
    generateAuthTokens: vi.fn().mockImplementation((userId) => {
      // We return a real signed JWT so the verification tests below still pass
      const accessToken = jwt.sign({ userId }, env.JWT_SECRET || "test-secret", { expiresIn: "2m" });
      return Promise.resolve({
        accessToken,
        refreshToken: "mock-refresh-token-string",
      });
    }),
  };
});

// mock drizzle db instance
const mockDb = vi.hoisted(() => {
  return {
    select: vi.fn().mockReturnThis(),
    from: vi.fn().mockReturnThis(),
    where: vi.fn().mockReturnThis(),
    limit: vi.fn().mockReturnThis(),
    delete: vi.fn().mockReturnThis(),
    insert: vi.fn().mockReturnThis(),
    values: vi.fn().mockReturnThis(),
  };
});

vi.mock("../db", () => ({
  db: mockDb,
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
    vi.mocked(queries.createUser).mockResolvedValue(true);

    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      email: "john@example.com",
      password: "password123",
    });

    expect(response.status).toBe(201);
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
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when phoneNumber is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      email: "john@example.com",
      password: "password123",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when email is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      password: "password123",
    });

    expect(response.status).toBe(400);
    expect(queries.createUser).not.toHaveBeenCalled();
  });

  it("should return 400 when password is missing", async () => {
    const response = await request(app).post("/auth/signup").send({
      fullName: "John Doe",
      phoneNumber: "1234567890",
      email: "john@example.com",
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
      password: "password123",
    });

    expect(response.status).toBe(409);
  });
});

describe("POST /auth/login", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should return an accessToken and set a refreshToken cookie", async () => {
    const mockUser = await createMockUser();
    vi.mocked(queries.getUserByEmail).mockResolvedValue(mockUser);

    const response = await request(app).post("/auth/login").send({
      email: "john@example.com",
      password: "password123",
    });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("accessToken");
    expect(response.body.accessToken).toBeTypeOf("string");

    // check if cookie is set
    const cookies = response.headers["set-cookie"];
    expect(cookies).toBeDefined();
    expect(cookies[0]).toContain("refreshToken");
    expect(cookies[0]).toContain("HttpOnly");

    const payload = jwt.verify(
      response.body.accessToken,
      env.JWT_SECRET || "test-secret",
    ) as jwt.JwtPayload;
    expect(payload.userId).toBe(1);
  });

  it("should return 400 when user does not exist", async () => {
    vi.mocked(queries.getUserByEmail).mockResolvedValue(null);

    const response = await request(app).post("/auth/login").send({
      email: "nonexistent@example.com",
      password: "password123",
    });

    expect(response.status).toBe(400);
  });

  it("should return 400 when password is incorrect", async () => {
    const mockUser = await createMockUser();
    vi.mocked(queries.getUserByEmail).mockResolvedValue(mockUser);

    const response = await request(app).post("/auth/login").send({
      email: "john@example.com",
      password: "wrong_password",
    });

    expect(response.status).toBe(400);
  });
});

// tests for refresh logic
describe("POST /auth/refresh", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should return 401 if no refresh token cookie is provided", async () => {
    const response = await request(app).post("/auth/refresh");
    expect(response.status).toBe(401);
    expect(response.body.error).toBe("No refresh token provided");
  });

  it("should return 401 if token is not found in DB or expired", async () => {
    // Mock DB to return empty array (token not found)
    // The chain is: db.select().from().where().limit()
    mockDb.limit.mockResolvedValue([]); 

    const response = await request(app)
      .post("/auth/refresh")
      .set("Cookie", ["refreshToken=some-invalid-token"]);

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
    };
    mockDb.limit.mockResolvedValue([validStoredToken]);

    // mock db delete
    mockDb.delete.mockReturnValue({
      where: vi.fn().mockResolvedValue(true),
    });

    const response = await request(app)
      .post("/auth/refresh")
      .set("Cookie", ["refreshToken=valid-old-token"]);

    expect(response.status).toBe(200);
    
    // check if got new Access Token
    expect(response.body).toHaveProperty("accessToken");
    
    // check if attempted to delete old token -- rotation
    expect(mockDb.delete).toHaveBeenCalled();
  });
});