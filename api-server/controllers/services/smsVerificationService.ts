import twilio from "twilio";
import {
  TWILIO_SID,
  TWILIO_AUTH,
  TWILIO_VERIFY_SERVICE,
  MOCK_TWILIO_SMS,
} from "../../env.js";

const client = twilio(TWILIO_SID, TWILIO_AUTH);

/**
 * Automatically sends an OTP to a phone number.
 */
export async function autoSendOTP(phoneNumber: string) {
  if (MOCK_TWILIO_SMS) {
    const mockOtp = Math.floor(100000 + Math.random() * 900000).toString();
    console.log(`[Auto-Mock OTP] to ${phoneNumber}: ${mockOtp}`);
    return;
  }

  await client.verify.v2
    .services(TWILIO_VERIFY_SERVICE)
    .verifications.create({ to: phoneNumber, channel: "sms" });
}
