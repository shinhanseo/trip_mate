export async function createNotification(
    client: any,
    input: {
        userId: number;
        type: string;
        title: string;
        body: string;
        targetType?: string;
        targetId?: number;
    }
) {
    await client.query(
        `
      insert into notifications (
        user_id,
        type,
        title,
        body,
        target_type,
        target_id
      )
      values ($1, $2, $3, $4, $5, $6)
      `,
        [
            input.userId,
            input.type,
            input.title,
            input.body,
            input.targetType ?? null,
            input.targetId ?? null,
        ]
    );
}
