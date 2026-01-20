import { ElevenLabsClient } from "@elevenlabs/elevenlabs-js";

export async function getWebrtcTokenForAgent() {
  const apiKey = process.env.ELEVENLABS_API_KEY;
  const agentId = process.env.ELEVENLABS_AGENT_ID;

  if (!apiKey || !agentId) {
    if (process.env.NODE_ENV === 'test') {
      return { token: "test-token" };
    }
    throw new Error("Missing ElevenLabs credentials");
  }

  const client = new ElevenLabsClient({ apiKey });

  const tokenResponse = await client.conversationalAi.conversations.getWebrtcToken({
    agentId: agentId,
  });

  return tokenResponse;
}