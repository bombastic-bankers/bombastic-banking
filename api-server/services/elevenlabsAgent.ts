import { ElevenLabsClient } from "@elevenlabs/elevenlabs-js";

const ELEVENLABS_API_KEY = process.env.ELEVENLABS_API_KEY!;
const ELEVENLABS_AGENT_ID = process.env.ELEVENLABS_AGENT_ID!;

const client = new ElevenLabsClient({
  apiKey: ELEVENLABS_API_KEY,
  environment: "https://api.elevenlabs.io",
});

/**
 * Ask ElevenLabs for a short-lived WebRTC token for the private agent.
 */
export async function getWebrtcTokenForAgent() {
  const tokenResponse = await client.conversationalAi.conversations.getWebrtcToken({
    agentId: ELEVENLABS_AGENT_ID,
  });

  return tokenResponse;
}