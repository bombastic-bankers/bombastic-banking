import twilio from "twilio";
import env from "../env.js";

const client = twilio(env.TWILIO_SID, env.TWILIO_AUTH);

/** * Sends a verification email via Twilio Verify.
 * Twilio handles the token generation and SendGrid delivery automatically.
 */
export async function sendVerificationEmail(email: string) {
  await client.verify.v2
    .services(env.TWILIO_VERIFY_SERVICE)
    .verifications.create({
      to: email,
      channel: "email",
    });
}
export async function checkEmailOTP(email: string, token: string) {
  const verificationCheck = await client.verify.v2
    .services(env.TWILIO_VERIFY_SERVICE)
    .verificationChecks.create({ to: email, code: token });

  return verificationCheck.status === "approved";
}
