import express from "express";
import cors from "cors";
import { authenticate } from "./middleware/auth.js";
import { validationError, anyError } from "./middleware/error.js";
import { getUserInfo, login, signUp } from "./controllers/users.js";
import {
  confirmCashDeposit,
  endTouchlessSession,
  initiateCashDeposit,
  startTouchlessSession,
  withdrawCash,
} from "./controllers/atm.js";
import { ablyAuth } from "./controllers/ably.js";

const app = express();
app.use(cors());
app.use(express.json());

app.get("/auth/ably", ablyAuth);
app.post("/auth/signup", signUp);
app.post("/auth/login", login);

app.use(authenticate);

app.get("/userinfo", getUserInfo);

app.post("/touchless/:atmId", startTouchlessSession);
app.delete("/touchless/:atmId", endTouchlessSession);
app.post("/touchless/:atmId/withdraw", withdrawCash);
app.post("/touchless/:atmId/initiate-deposit", initiateCashDeposit);
app.post("/touchless/:atmId/confirm-deposit", confirmCashDeposit);

app.use(validationError);
app.use(anyError);

export default app;
