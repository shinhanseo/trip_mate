import { Router, Response } from "express";
import { authRequired, AuthRequest } from "../middleware/authRequired";
import { ok, fail } from "../utils/response";
import { prisma } from "../lib/prisma";

const router = Router();

router.get("/", authRequired, async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;
  const limit = Number(req.query.limit ?? 50);

  if (!Number.isInteger(limit) || limit < 1 || limit > 100) {
    return fail(res, 400, "invalid limit");
  }

  try {
    const notifications = await prisma.notification.findMany({
      where: {
        userId: BigInt(userId),
        deletedAt: null,
      },
      orderBy: [
        { createdAt: "desc" },
        { id: "desc" },
      ],
      take: limit,
    });

    return ok(res, {
      items: notifications.map((notification) => ({
        id: Number(notification.id),
        type: notification.type,
        title: notification.title,
        body: notification.body,
        targetType: notification.targetType,
        targetId:
          notification.targetId === null
            ? null
            : Number(notification.targetId),
        readAt: notification.readAt,
        createdAt: notification.createdAt,
      })),
    });
  } catch (error: any) {
    return fail(res, 500, "failed to load notifications", error?.message);
  }
});

router.get("/unread-count", authRequired, async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;

  try {
    const count = await prisma.notification.count({
      where: {
        userId: BigInt(userId),
        readAt: null,
        deletedAt: null,
      },
    });

    return ok(res, {
      count,
    });
  } catch (error: any) {
    return fail(res, 500, "failed to load unread notification count", error?.message);
  }
});

router.patch("/:id/read", authRequired, async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;
  const notificationId = Number(req.params.id);

  if (!Number.isInteger(notificationId) || notificationId <= 0) {
    return fail(res, 400, "invalid notification id");
  }

  try {
    const updateRes = await prisma.notification.updateMany({
      where: {
        id: BigInt(notificationId),
        userId: BigInt(userId),
        deletedAt: null,
      },
      data: {
        readAt: new Date(),
      },
    });

    if (updateRes.count === 0) {
      return fail(res, 404, "notification not found");
    }

    return ok(res, {
      message: "notification read",
    });
  } catch (error: any) {
    return fail(res, 500, "failed to read notification", error?.message);
  }
});

router.patch("/read-all", authRequired, async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;

  try {
    const updateRes = await prisma.notification.updateMany({
      where: {
        userId: BigInt(userId),
        readAt: null,
        deletedAt: null,
      },
      data: {
        readAt: new Date(),
      },
    });

    return ok(res, {
      updatedCount: updateRes.count,
    });
  } catch (error: any) {
    return fail(res, 500, "failed to read notifications", error?.message);
  }
});

router.delete("/:id", authRequired, async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;
  const notificationId = Number(req.params.id);
  const now = new Date();

  if (!Number.isInteger(notificationId) || notificationId <= 0) {
    return fail(res, 400, "invalid notification id");
  }

  try {
    const updateRes = await prisma.notification.updateMany({
      where: {
        id: BigInt(notificationId),
        userId: BigInt(userId),
        deletedAt: null,
      },
      data: {
        deletedAt: now,
        readAt: now,
      },
    });

    if (updateRes.count === 0) {
      return fail(res, 404, "notification not found");
    }

    return ok(res, {
      message: "notification deleted",
    });
  } catch (error: any) {
    return fail(res, 500, "failed to delete notification", error?.message);
  }
});

router.delete("/", authRequired, async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;
  const now = new Date();

  try {
    const updateRes = await prisma.notification.updateMany({
      where: {
        userId: BigInt(userId),
        deletedAt: null,
      },
      data: {
        deletedAt: now,
        readAt: now,
      },
    });

    return ok(res, {
      deletedCount: updateRes.count,
    });
  } catch (error: any) {
    return fail(res, 500, "failed to delete notifications", error?.message);
  }
});

export default router;
