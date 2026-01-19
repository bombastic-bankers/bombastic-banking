import type { Request, Response } from "express";
import { getWebrtcTokenForAgent } from "../services/elevenlabsAgent.js";

/**
 * Returns a short-lived ElevenLabs WebRTC token for the private voice agent.
 */
export async function getVoiceToken(req: Request, res: Response) {
    const tokenResponse = await getWebrtcTokenForAgent();
    return res.status(200).json({
        agentId: process.env.ELEVENLABS_AGENT_ID,
        ...tokenResponse,
    });
}
