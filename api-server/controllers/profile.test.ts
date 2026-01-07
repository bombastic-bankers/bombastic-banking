import { describe, it, expect, vi, beforeEach } from "vitest";

/**
 * Mock the database query layer.
 * Ensures unit tests do NOT touch the real database.
 */
vi.mock("../db/queries/index.js", () => ({
    updateUserProfile: vi.fn()
}));

import * as queries from "../db/queries/index.js";
import { updateProfile } from "./profile.js";

/**
 * Helper function to mock Express `Response` object
 * Allows us to track calls to `status()` and `json()`
 */
function mockRes() {
    const res: any = {};
    res.status = vi.fn().mockReturnValue(res);
    res.json = vi.fn().mockReturnValue(res);
    return res;
}

describe("updateProfile controller", () => {
    const updateUserProfileMock = vi.mocked(queries.updateUserProfile);

    // Reset all mocks before each test to avoid test pollution
    beforeEach(() => {
        vi.clearAllMocks();
    });

    // Test: user is not authenticated (no userId)
    // Expected: 401 Unauthorized and no DB interaction
    it("401 if userId missing", async () => {
        const req: any = { userId: undefined, body: { fullName: "A" } };
        const res = mockRes();

        await updateProfile(req, res);

        expect(res.status).toHaveBeenCalledWith(401);
        expect(res.json).toHaveBeenCalledWith({ error: "Unauthorized" });
        expect(updateUserProfileMock).not.toHaveBeenCalled();
    });

    // Test: request body is empty
    // Expected: 400 Validation error and DB not called
    it("400 if body is invalid (no fields)", async () => {
        const req: any = { userId: 1, body: {} };
        const res = mockRes();

        await updateProfile(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(updateUserProfileMock).not.toHaveBeenCalled();
        expect(res.json.mock.calls[0][0].error).toBe("Validation error");
    });

    // Test: invalid phone number format
    // Expected: 400 Validation error
    it("400 if phoneNumber invalid", async () => {
        const req: any = { userId: 1, body: { phoneNumber: "123" } };
        const res = mockRes();

        await updateProfile(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(updateUserProfileMock).not.toHaveBeenCalled();
    });

    // Test: valid input but user does not exist in DB
    // Expected: 404 User not found
    it("404 if user not found (update returns null)", async () => {
        updateUserProfileMock.mockResolvedValue(null as any);

        const req: any = { userId: 1, body: { fullName: "New Name" } };
        const res = mockRes();

        await updateProfile(req, res);

        expect(updateUserProfileMock).toHaveBeenCalledWith(1, { fullName: "New Name" });
        expect(res.status).toHaveBeenCalledWith(404);
        expect(res.json).toHaveBeenCalledWith({ error: "User not found" });
    });

    // Test: successful profile update
    // Expected: updated user data returned with 200 OK
    it("200 returns updated user if success", async () => {
        updateUserProfileMock.mockResolvedValue({
            userId: 1,
            fullName: "New Name",
            phoneNumber: "91234567",
            email: "test@example.com"
        } as any);

        const req: any = { userId: 1, body: { fullName: "New Name" } };
        const res = mockRes();

        await updateProfile(req, res);

        expect(updateUserProfileMock).toHaveBeenCalledWith(1, { fullName: "New Name" });
        expect(res.json).toHaveBeenCalledWith({
            userId: 1,
            fullName: "New Name",
            phoneNumber: "91234567",
            email: "test@example.com"
        });
    });

    // Test: unexpected database failure
    // Expected: 500 Internal Server Error
    it("500 if DB throws error", async () => {
        updateUserProfileMock.mockRejectedValue(new Error("DB down"));

        const req: any = { userId: 1, body: { fullName: "New Name" } };
        const res = mockRes();

        await updateProfile(req, res);

        expect(res.status).toHaveBeenCalledWith(500);
        expect(res.json).toHaveBeenCalledWith({ error: "Server error" });
    });

    // Test: request contains forbidden/unknown fields
    // Expected: 400 Validation error and DB not called
    it("400 if body contains unknown fields (e.g. hashedPin)", async () => {
        const req: any = {
            userId: 1,
            body: {
                hashedPin: "123456"
            }
        };
        const res = mockRes();

        await updateProfile(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json.mock.calls[0][0].error).toBe("Validation error");

        // Ensure DB is NOT touched
        expect(updateUserProfileMock).not.toHaveBeenCalled();
    });
});

