import express from "express";
import cors from "cors";
import morgan from "morgan";
import { authenticate, requireVerified } from "./middleware/auth.js";
import { validationError, anyError } from "./middleware/error.js";
import {
  getUserAccOverview,
  login,
  signUp,
  updateProfile,
  getUserProfile,
  refreshSession,
} from "./controllers/users.js";
import {
  exit,
  withdrawCash,
  startCashDeposit,
  countCashDeposit,
  confirmCashDeposit,
  cancelCashDeposit,
} from "./controllers/atm.js";
import { ablyAuth } from "./controllers/ably.js";
import { getContactsByPhoneNumber } from "./controllers/contacts.js";
import env from "./env.js";
import { atmParam } from "./middleware/atm.js";
import { transferMoney, getTransactionHistory} from "./controllers/transaction.js";
import ngrok from "@ngrok/ngrok";
import { getVoiceToken } from "./controllers/voice.js";
import {
  sendSMSVerification,
  confirmSMSVerification,
  sendEmailVerification,
  confirmEmailVerification,
} from "./controllers/verify.js";

const TESTING = process.env.NODE_ENV === "test";

const app = express();
!TESTING && app.use(morgan("dev"));
app.use(cors());
app.use(express.json());

app.post("/auth/signup", signUp);
app.post("/auth/login", login);
app.post("/auth/refresh", refreshSession);
app.post("/auth/ably", ablyAuth);

app.use(authenticate);

app.post("/verification/sms", sendSMSVerification);
app.post("/verification/sms/confirm", confirmSMSVerification);
app.post("/verification/email", sendEmailVerification);
app.get("/verification/email/confirm", confirmEmailVerification);

app.use(requireVerified);

app.get("/account-overview", getUserAccOverview);
app.get("/profile", getUserProfile);
app.patch("/profile", updateProfile);

const touchless = express.Router({ mergeParams: true });
touchless.use(atmParam);
touchless.post("/withdraw", withdrawCash);
touchless.post("/deposit/start", startCashDeposit);
touchless.post("/deposit/count", countCashDeposit);
touchless.post("/deposit/confirm", confirmCashDeposit);
touchless.post("/deposit/cancel", cancelCashDeposit);
touchless.post("/exit", exit);
app.use("/touchless/:atmId", touchless);

app.post("/transfer", transferMoney);
app.get("/transaction-history", getTransactionHistory)
app.get("/contacts", getContactsByPhoneNumber);

app.get("/voice/token", getVoiceToken);

app.use(validationError);
app.use(anyError);

if (!TESTING) {
  const PORT = env.PORT || 3000;
  app.listen(PORT, async () => {
    console.log(`Server running at http://localhost:${PORT}`);

    if (env.NGROK_AUTHTOKEN) {
      const listener = await ngrok.forward({ addr: PORT, authtoken: env.NGROK_AUTHTOKEN });
      console.log(`Forwarding to ngrok at ${listener.url()}`);
    }
  });
}

export default app;
