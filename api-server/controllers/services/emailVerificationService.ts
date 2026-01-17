import sgMail from "@sendgrid/mail";
import {SENDGRID_VERIFIED_EMAIL,SENDGRID_API_KEY, BASE_URL } from "../../env.js";

/** Sends a verification email to the user with a unique token link.
 */
sgMail.setApiKey(SENDGRID_API_KEY);

export async function sendVerificationEmail(email: string, token: string) {
  const link = `${BASE_URL}/verify/email/confirm?token=${token}`;

  const msg = {
    to: email,
    from: SENDGRID_VERIFIED_EMAIL,
    subject: "Verify Your Account - Bombastic Banking",
    html: `<p>Click <a href="${link}">here</a> to verify your email. This link expires in 24 hours.</p>`,
  };

  try {
    await sgMail.send(msg);
    console.log(`Verification email sent to ${email}`);
  } catch (error: any) {
    console.error("SendGrid Error Details:", error.response?.body || error.message);
    throw new Error("Failed to send verification email via SendGrid");
  }
}