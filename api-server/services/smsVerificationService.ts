import twilio from "twilio";
import env from "../env.js";

const client = twilio(env.TWILIO_SID, env.TWILIO_AUTH);

/**
 * Automatically sends an OTP to a phone number.
 */
export async function sendOTP(phoneNumber: string) {
  await client.verify.v2
    .services(env.TWILIO_VERIFY_SERVICE)
    .verifications.create({ to: phoneNumber, channel: "sms" });
}

/**
 * Checks the OTP with Twilio to see if it is valid.
 */
export async function checkOTP(phoneNumber: string, otp: string) {
  const result = await client.verify.v2
    .services(env.TWILIO_VERIFY_SERVICE)
    .verificationChecks.create({
      to: phoneNumber,
      code: otp,
    });
  return result.status === "approved";
}
