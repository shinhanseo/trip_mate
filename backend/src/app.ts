import express, { Request, Response } from 'express';
import session from "express-session";
import cors from 'cors';

import placeSearchRouter from "./routes/placeSearch";
import jejuWeatherRouter from "./routes/jejuWeather";
import oauthRouter from "./routes/oauth";
import meetingRouter from "./routes/meeting";
import userRouter from "./routes/user";

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(
  session({
    secret: "your-secret-key",
    resave: false,
    saveUninitialized: false,
  })
);

app.use("/api/place", placeSearchRouter);
app.use("/api/weather", jejuWeatherRouter);
app.use("/api/auth", oauthRouter);
app.use("/api/meeting", meetingRouter);
app.use("api/user", userRouter);

app.get("/health", (req: Request, res: Response) => {
  res.status(200).json({
    status: "ok",
    timestamp: new Date().toISOString(),
  });
});

// 서버 시작
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});