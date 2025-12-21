import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../index.js";
import * as elevenLabsService from "../services/elevenlabsAgent.js";
import { NextFunction, Request, Response } from "express";

vi.mock("../services/elevenlabsAgent.js");

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

describe("GET /voice/token", () => {
  const MOCK_AGENT_ID = "wefaf32r";

  beforeEach(() => {
    vi.clearAllMocks();
    process.env.ELEVENLABS_AGENT_ID = MOCK_AGENT_ID;
  });

  it("should return a 200 and the voice token data", async () => {
    const mockTokenResponse = {
      token: "mock-webrtc-token-123",
      expiresAt: 1737300000,
    };
    vi.mocked(elevenLabsService.getWebrtcTokenForAgent).mockResolvedValue(mockTokenResponse);

    const response = await request(app).get("/voice/token");

    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      agentId: MOCK_AGENT_ID,
      token: "mock-webrtc-token-123",
      expiresAt: 1737300000,
    });
    expect(elevenLabsService.getWebrtcTokenForAgent).toHaveBeenCalledTimes(1);
  });
});
