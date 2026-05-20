import { prisma } from "../../lib/prisma";
import { firebaseMessaging } from "./firebase-admin";

type SendPushToUsersInput = {
  userIds: number[];
  title: string;
  body: string;
  targetType?: string;
  targetId?: number;
};

export async function sendPushToUsers(input: SendPushToUsersInput) {
  const uniqueUserIds = [...new Set(input.userIds)].filter((id) =>
    Number.isInteger(id) && id > 0
  );

  if (uniqueUserIds.length === 0) {
    return {
      sentCount: 0,
      failedCount: 0,
    };
  }

  const tokenRows = await prisma.userFcmToken.findMany({
    where: {
      userId: {
        in: uniqueUserIds.map((id) => BigInt(id)),
      },
      revokedAt: null,
    },
    select: {
      token: true,
    },
  });

  const tokens = [...new Set(tokenRows.map((row) => row.token))];

  if (tokens.length === 0) {
    return {
      sentCount: 0,
      failedCount: 0,
    };
  }

  const response = await firebaseMessaging.sendEachForMulticast({
    tokens,
    notification: {
      title: input.title,
      body: input.body,
    },
    data: {
      targetType: input.targetType ?? "",
      targetId: input.targetId == null ? "" : String(input.targetId),
    },
  });

  const invalidTokens: string[] = [];

  response.responses.forEach((result, index) => {
    if (result.success) return;

    const code = result.error?.code;

    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      invalidTokens.push(tokens[index]);
    }
  });

  if (invalidTokens.length > 0) {
    await prisma.userFcmToken.updateMany({
      where: {
        token: {
          in: invalidTokens,
        },
      },
      data: {
        revokedAt: new Date(),
        updatedAt: new Date(),
      },
    });
  }

  return {
    sentCount: response.successCount,
    failedCount: response.failureCount,
  };
}