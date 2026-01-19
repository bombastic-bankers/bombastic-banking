import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import type { NextFunction, Request, Response } from "express";
import app from "../index.js";
import * as elevenlabs from "../services/elevenlabsAgent.js";

vi.mock("../services/elevenlabsAgent", () => ({
    getWebrtcTokenForAgent: vi.fn(),
}));

vi.mock("../middleware/auth", () => ({
    authenticate: (req: Request, _: Response, next: NextFunction) => {
        req.userId = 1;
        next();
    },
}));

describe("GET /voice/token", () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it("should return a voice token", async () => {
        const getTokenMock = vi.mocked(elevenlabs.getWebrtcTokenForAgent);

        getTokenMock.mockResolvedValue({
            token: "fake-webrtc-token",
        });

        const res = await request(app).get("/voice/token");

        expect(res.status).toBe(200);
        expect(res.body).toEqual({ token: "fake-webrtc-token" });
        expect(getTokenMock).toHaveBeenCalledTimes(1);
    });
});
