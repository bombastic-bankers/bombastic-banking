import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../index.js";
import * as queries from "../db/queries/index.js";

vi.mock("../db/queries");

describe("POST /contacts", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should retrieve contacts with valid phone numbers", async () => {
    const mockContacts = [
      { fullName: "Alice Smith", phoneNumber: "+651234567890" },
      { fullName: "Bob Johnson", phoneNumber: "+651234567891" },
    ];

    vi.mocked(queries.getContactsByPhoneNumber).mockResolvedValue(mockContacts);

    const response = await request(app)
      .post("/contacts")
      .send(["+651234567890", "+651234567891"]);

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("token");
    expect(response.body).toHaveProperty("contacts");
    expect(response.body.contacts).toEqual(mockContacts);
    expect(queries.getContactsByPhoneNumber).toHaveBeenCalledWith([
      "+651234567890",
      "+651234567891",
    ]);
  });

  it("should return 409 when phone numbers are invalid", async () => {
    vi.mocked(queries.getContactsByPhoneNumber).mockResolvedValue([]);

    const response = await request(app)
      .post("/contacts")
      .send(["+651234567890", "+651234567891"]);

    expect(response.status).toBe(409);
    expect(response.body).toEqual({
      error: "Invalid list of phone numbers",
    });
  });

  it("should return 400 when phone numbers are not in E.164 format", async () => {
    const response = await request(app)
      .post("/contacts")
      .send(["1234567890", "9876543210"]);

    expect(response.status).toBe(400);
    expect(queries.getContactsByPhoneNumber).not.toHaveBeenCalled();
  });

  it("should return 200 when request body is empty", async () => {
    const response = await request(app)
      .post("/contacts")
      .send([]);

    expect(response.status).toBe(200);
    expect(queries.getContactsByPhoneNumber).not.toHaveBeenCalled();
  });

  it("should return 400 when request body is not an array", async () => {
    const response = await request(app)
      .post("/contacts")
      .send({ phoneNumber: "+651234567890" });

    expect(response.status).toBe(400);
    expect(queries.getContactsByPhoneNumber).not.toHaveBeenCalled();
  });
});
