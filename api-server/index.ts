import express from "express";
import cors from "cors";
import morgan from "morgan";
import { authenticate } from "./middleware/auth.js";
import { validationError, anyError } from "./middleware/error.js";
import { getUserInfo, login, signUp, refreshSession } from "./controllers/users.js"; // add refreshSession
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
import { transferMoney } from "./controllers/transaction.js";
import ngrok from "@ngrok/ngrok";

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

app.get("/userinfo", getUserInfo);

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
app.get("/contacts", getContactsByPhoneNumber);

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
