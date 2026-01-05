import express from "express";
import cors from "cors";
import morgan from "morgan";
import { authenticate } from "./middleware/auth.js";
import { validationError, anyError } from "./middleware/error.js";
import { getUserInfo, login, signUp } from "./controllers/users.js";
import {
  exit,
  withdrawCash,
  startCashDeposit,
  countCashDeposit,
  confirmCashDeposit,
  cancelCashDeposit,
} from "./controllers/atm.js";
import { ablyAuth } from "./controllers/ably.js";
import { PORT } from "./env.js";
import { atmParam } from "./middleware/atm.js";
import { updateProfile } from "./controllers/updateProfile.js";

const TESTING = process.env.NODE_ENV === "test";

const app = express();
!TESTING && app.use(morgan("dev"));
app.use(cors());
app.use(express.json());

app.get("/auth/ably", ablyAuth);
app.post("/auth/signup", signUp);
app.post("/auth/login", login);
app.post("/auth/ably", ablyAuth);

app.use(authenticate);

app.get("/userinfo", getUserInfo);
app.put("/profile", updateProfile)

const touchless = express.Router({ mergeParams: true });
touchless.use(atmParam);
touchless.post("/withdraw", withdrawCash);
touchless.post("/deposit/start", startCashDeposit);
touchless.post("/deposit/count", countCashDeposit);
touchless.post("/deposit/confirm", confirmCashDeposit);
touchless.post("/deposit/cancel", cancelCashDeposit);
touchless.post("/exit", exit);
app.use("/touchless/:atmId", touchless);

app.use(validationError);
app.use(anyError);

if (!TESTING) {
  app.listen(PORT || 3000, () => {
    console.log("Server running at http://localhost:3000");
  });
}

export default app;
