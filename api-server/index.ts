import express from "express";
import cors from "cors";
import { authenticate } from "./middleware/auth";
import { login, signUp } from "./controllers/users";
import {
  endTouchlessSession,
  startTouchlessSession,
  withdrawCash,
} from "./controllers/atm";
import { pusherAuth } from "./controllers/pusher";

const app = express();
app.use(cors());
app.use(express.json());

app.post("/auth/signup", signUp);
app.post("/auth/login", login);
app.post("/pusher/auth", pusherAuth);

app.use(authenticate);

app.post("/touchless/:atmId", startTouchlessSession);
app.delete("/touchless/:atmId", endTouchlessSession);
app.post("/touchless/:atmId/withdraw", withdrawCash);

export default app;
