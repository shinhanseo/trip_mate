import { Response } from "express";

export function ok(res: Response, data: any = {}, status = 200) {
  return res.status(status).json({
    success: true,
    data,
  });
}

export function fail(
  res: Response,
  status: number,
  message: string,
  error?: any
) {
  return res.status(status).json({
    success: false,
    message,
    ...(error !== undefined ? { error } : {}),
  });
}