import { Router, Response } from "express";
import { authRequired, AuthRequest } from "../middleware/authRequired";
import { ok, fail } from "../utils/response";
import { prisma } from "../lib/prisma";

const router = Router();

const allowedTargetTypes = ["user", "meeting", "chat_room", "chat_message"];

router.post("/", authRequired, async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;
  const { targetType, targetId, reason, detail } = req.body;

  if (
    typeof targetType !== "string" ||
    !allowedTargetTypes.includes(targetType) ||
    targetId === null ||
    targetId === undefined ||
    typeof reason !== "string" ||
    reason.trim().length === 0
  ) {
    return fail(res, 400, "invalid value");
  }

  if (targetType === "user" && BigInt(targetId) === BigInt(userId)) {
    return fail(res, 400, "report myself impossible");
  }

  try {
    await prisma.report.create({
      data: {
        reporterId: userId,
        targetType,
        targetId: BigInt(targetId),
        reason: reason.trim(),
        detail: typeof detail === "string" ? detail.trim() : null,
      },
    });

    return ok(res, { message: "report submitted" }, 201);
  } catch (error: any) {
    return fail(res, 500, "failed to report");
  }
});

export default router;
