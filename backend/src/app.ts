import express, { Request, Response } from "express";
import session from "express-session";
import cors from "cors";
import http from "node:http";

import placeSearchRouter from "./routes/placeSearch";
import jejuWeatherRouter from "./routes/jejuWeather";
import oauthRouter from "./routes/oauth";
import meetingRouter from "./routes/meeting";
import userRouter from "./routes/user";
import uploadRouter from "./routes/upload";
import chatRouter from "./routes/chat";
import { setupChatSocket } from "./socket/chatSocket";

const app = express();
const PORT = Number(process.env.PORT) || 3000;

app.use(
  cors({
    origin: true,
    credentials: true,
  })
);

app.use(express.json());

app.use(
  session({
    secret: process.env.SESSION_SECRET || "dev-session-secret",
    resave: false,
    saveUninitialized: false,
  })
);

app.use("/api/place", placeSearchRouter);
app.use("/api/weather", jejuWeatherRouter);
app.use("/api/auth", oauthRouter);
app.use("/api/meeting", meetingRouter);
app.use("/api/user", userRouter);
app.use("/api/upload", uploadRouter);
app.use("/api/chat", chatRouter);

app.get("/health", (req: Request, res: Response) => {
  res.status(200).json({
    status: "ok",
    timestamp: new Date().toISOString(),
  });
});

const server = http.createServer(app);

setupChatSocket(server);

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});
