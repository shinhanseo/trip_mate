// backend/src/middleware/authRequired.ts
import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

const JWT_ACCESS_SECRET = process.env.JWT_ACCESS_SECRET!;

export interface AuthUser {
  userId: number;
  tokenVersion?: number;
}

export interface AuthRequest extends Request {
  user?: AuthUser;
}

export function authRequired(
  req: AuthRequest,
  res: Response,
  next: NextFunction
) {
  const authHeader = req.header("authorization") || "";
  const [scheme, token] = authHeader.split(" ");

  if (scheme !== "Bearer" || !token) {
    return res.status(401).json({ message: "access token required" });
  }

  try {
    const payload = jwt.verify(token, JWT_ACCESS_SECRET) as AuthUser;
    req.user = payload;
    next();
  } catch {
    return res.status(401).json({ message: "invalid or expired access token" });
  }
}