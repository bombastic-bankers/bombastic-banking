import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import { NextFunction, Request, Response } from "express";
import app from "../index.js";
import * as queries from "../db/queries/index.js";

vi.mock("../db/queries");
vi.mock("../middleware/auth", () => ({
  authenticate: (req: Request, _: Response, next: NextFunction) => {
    req.userId = 1;
    next();
  },
}));

describe("GET /contacts", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should retrieve contacts with valid phone numbers", async () => {
    const mockContacts = [
      { fullName: "Alice Smith", phoneNumber: "+651234567890" },
      { fullName: "Bob Johnson", phoneNumber: "+651234567891" },
    ];

    vi.mocked(queries.getContactsByPhoneNumber).mockResolvedValue(mockContacts);

    const response = await request(app).get("/contacts").send(["+651234567890", "+651234567891"]);

    expect(response.status).toBe(200);
    expect(response.body).toEqual(mockContacts);
    expect(queries.getContactsByPhoneNumber).toHaveBeenCalledWith(["+651234567890", "+651234567891"]);
  });

  it("should return 400 when phone numbers are invalid", async () => {
    vi.mocked(queries.getContactsByPhoneNumber).mockResolvedValue([]);

    const response = await request(app).get("/contacts").send(["+65123abc", "+65123f"]);

    expect(response.status).toBe(400);
  });

  it("should return 400 when phone numbers are not in E.164 format", async () => {
    const response = await request(app).get("/contacts").send(["1234567890", "9876543210"]);

    expect(response.status).toBe(400);
    expect(queries.getContactsByPhoneNumber).not.toHaveBeenCalled();
  });

  it("should return 200 when request body is empty", async () => {
    const response = await request(app).get("/contacts").send([]);

    expect(response.status).toBe(200);
    expect(queries.getContactsByPhoneNumber).not.toHaveBeenCalled();
  });

  it("should return 400 when request body is not an array", async () => {
    const response = await request(app).get("/contacts").send({ phoneNumber: "+651234567890" });

    expect(response.status).toBe(400);
    expect(queries.getContactsByPhoneNumber).not.toHaveBeenCalled();
  });
});
