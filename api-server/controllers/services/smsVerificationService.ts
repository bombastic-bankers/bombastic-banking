import twilio from "twilio";
import {
  TWILIO_SID,
  TWILIO_AUTH,
  TWILIO_VERIFY_SERVICE,
} from "../../env.js";

const client = twilio(TWILIO_SID, TWILIO_AUTH);

/**
 * Automatically sends an OTP to a phone number.
 */
export async function autoSendOTP(phoneNumber: string) {
  await client.verify.v2
    .services(TWILIO_VERIFY_SERVICE)
    .verifications.create({ to: phoneNumber, channel: "sms" });
}

