import nodemailer from "nodemailer";
import { EMAIL_USER, EMAIL_PASS, BASE_URL, MOCK_EMAIL } from "../../env.js";

/** Sends a verification email to the user with a unique token link.
 */

export async function sendVerificationEmail(email: string, token: string) {
  const link = `${BASE_URL}/verify/email/confirm?token=${token}`;

  if (MOCK_EMAIL) {
    console.log("\n--- [Mock Email Verification] ---");
    console.log('From: "OCBC Support" <' + EMAIL_USER + ">");
    console.log(`To: ${email}`);
    console.log(`Subject: Verify Your Account`);
    console.log(`Link: ${link}`);
    return;
  }

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: EMAIL_USER,
      pass: EMAIL_PASS,
    },
  });

  await transporter.sendMail({
    from: `"OCBC Support" <${EMAIL_USER}>`,
    to: email,
    subject: "Verify Your Account",
    html: `<p>Click <a href="${link}">here</a> to verify your email. This link expires in 24 hours.</p>`,
  });
}
