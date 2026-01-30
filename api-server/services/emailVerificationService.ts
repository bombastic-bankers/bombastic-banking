import nodemailer from "nodemailer";
import crypto from "crypto";
import env from "../env.js";
import lazy from "../lazy.js";

const transport = lazy(() =>
  nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: env.EMAIL_USER,
      pass: env.EMAIL_PASS,
    },
  }),
);

/** Send a verification email to the specified address with the given token. */
export async function sendVerificationEmail(email: string, token: string) {
  const link = `${env.BASE_URL}/verification/email/confirm?token=${token}`;

  try {
    await transport.sendMail({
      from: `"Bombastic Banking" <${env.EMAIL_USER}>`,
      to: email,
      subject: "Verify Your Account",
      html: `<p>Click <a href="${link}">here</a> to verify your email. This link expires in 24 hours.</p>`,
    });
  } catch (error) {
    console.error("Failed to send email verification:", error);
    throw error;
  }
}

/** Generate a random email verification token and its expiry date (24 hours from now). */
export function generateEmailToken() {
  const token = crypto.randomBytes(32).toString("hex");
  const expiry = new Date();
  expiry.setHours(expiry.getHours() + 24);
  return { token, expiry };
}
