import express from "express";
import cors from "cors";
import { authenticate } from "./middleware/auth";
import { login, signUp } from "./controllers/users";

const app = express();
app.use(cors());
app.use(express.json());

app.post("/auth/signup", signUp);
app.post("/auth/login", login);

app.get("/transactions/protected", authenticate, (req, res) => {
  res.json({
    message: "You accessed a protected route!",
    user: req.user,
  });
});

app.listen(process.env.PORT || 3000, () => {
  console.log("Server running at http://localhost:3000");
});
