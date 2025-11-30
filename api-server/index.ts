import express from "express";
import cors from "cors";
import morgan from "morgan";
import cookieParser from "cookie-parser"; // cookie parser for refresh token
import { authenticate } from "./middleware/auth.js";
import { validationError, anyError } from "./middleware/error.js";
import { getUserInfo, login, signUp, refreshSession } from "./controllers/users.js"; // add refreshSession
import {
  returnToIdle,
  indicateTouchless,
  withdrawCash,
  initiateCashDeposit,
  confirmCashDeposit,
} from "./controllers/atm.js";
import { ablyAuth } from "./controllers/ably.js";
import { PORT } from "./env.js";

const app = express();
app.use(morgan("dev"));
app.use(cors());

// when using "app.use(cors());", by default might block cookies bc our frontend is on localhost:5173
// if browser refuse to save the cookie, changing "app.use(cors());" to the one below might work
// app.use(cors({
//   origin: "http://localhost:5173", // Your frontend URL
//   credentials: true // Allow cookies
// }));

app.use(express.json());
app.use(cookieParser());

app.get("/auth/ably", ablyAuth);
app.post("/auth/signup", signUp);
app.post("/auth/login", login);
app.post("/auth/refresh", refreshSession);
app.post("/auth/ably", ablyAuth);

app.use(authenticate);

app.get("/userinfo", getUserInfo);

app.post("/touchless/:atmId/indicate-touchless", indicateTouchless);
app.post("/touchless/:atmId/return-to-idle", returnToIdle);
app.post("/touchless/:atmId/withdraw", withdrawCash);
app.post("/touchless/:atmId/initiate-deposit", initiateCashDeposit);
app.post("/touchless/:atmId/confirm-deposit", confirmCashDeposit);

app.use(validationError);
app.use(anyError);

if (process.env.NODE_ENV !== "test") {
  app.listen(PORT || 3000, () => {
    console.log("Server running at http://localhost:3000");
  });
}

export default app;
