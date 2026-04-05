import { Router, Response } from "express";
import { pool } from "../db";
import { authRequired, AuthRequest } from "../middleware/authRequired";
import { ok, fail } from "../utils/response";

const router = Router();

// 내가 joined 한 시점 이후 메시지 조회
router.get(
  "/meetings/:meetingId/messages",
  authRequired,
  async (req: AuthRequest, res: Response) => {
    const meetingId = Number(req.params.meetingId);
    const userId = req.user!.userId;

    if (!Number.isInteger(meetingId) || meetingId <= 0) {
      return fail(res, 400, "invalid meeting id");
    }

    const client = await pool.connect();

    try {
      const memberRes = await client.query(
        `
        select crm.joined_at, cr.id as room_id
        from chat_rooms cr
        join chat_room_members crm
          on crm.room_id = cr.id
         and crm.user_id = $2
        where cr.meeting_id = $1
        `,
        [meetingId, userId]
      );

      if (memberRes.rowCount === 0) {
        return fail(res, 403, "forbidden");
      }

      const joinedAt = memberRes.rows[0].joined_at;

      const roomRes = await client.query(
        `
        select id
        from chat_rooms
        where meeting_id = $1
        `,
        [meetingId]
      );

      if (roomRes.rowCount === 0) {
        return ok(res, {
          items: [],
        });
      }

      const roomId = roomRes.rows[0].id;

      const messageRes = await client.query(
        `
        select
          cm.id,
          cm.room_id,
          cm.sender_id,
          cm.content,
          cm.created_at,
          cm.updated_at,
          up.nickname as sender_nickname,
          up.profile_image_url as sender_profile_image_url
        from chat_messages cm
        join users u
          on u.id = cm.sender_id
        left join user_profiles up
          on up.user_id = u.id
        where cm.room_id = $1
          and cm.created_at >= $2
        order by cm.created_at asc, cm.id asc
        `,
        [roomId, joinedAt]
      );

      return ok(res, {
        items: messageRes.rows.map((row) => ({
          id: Number(row.id),
          roomId: Number(row.room_id),
          senderId: Number(row.sender_id),
          senderNickname: row.sender_nickname,
          senderProfileImageUrl: row.sender_profile_image_url,
          content: row.content,
          createdAt: row.created_at,
          updatedAt: row.updated_at,
        })),
      });
    } catch (error: any) {
      console.error("GET /chat/meetings/:meetingId/messages error:", error);
      return fail(res, 500, "failed to load chat messages");
    } finally {
      client.release();
    }
  }
);

router.post(
  "/meetings/:meetingId/messages",
  authRequired,
  async (req: AuthRequest, res: Response) => {
    const meetingId = Number(req.params.meetingId);
    const userId = req.user!.userId;
    const content =
      typeof req.body.content === "string" ? req.body.content.trim() : "";

    if (!Number.isInteger(meetingId) || meetingId <= 0) {
      return fail(res, 400, "invalid meeting id");
    }

    if (!content) {
      return fail(res, 400, "content is required");
    }

    if (content.length > 1000) {
      return fail(res, 400, "content is too long");
    }

    const client = await pool.connect();

    try {
      await client.query("begin");

      const memberRes = await client.query(
        `
        select mm.user_id
        from meeting_members mm
        where mm.meeting_id = $1
          and mm.user_id = $2
          and mm.status = 'joined'
        for update
        `,
        [meetingId, userId]
      );

      if (memberRes.rowCount === 0) {
        await client.query("rollback");
        return fail(res, 403, "forbidden");
      }

      const roomRes = await client.query(
        `
        select cr.id
        from chat_rooms cr
        where cr.meeting_id = $1
        `,
        [meetingId]
      );

      if (roomRes.rowCount === 0) {
        await client.query("rollback");
        return fail(res, 404, "chat room not found");
      }

      const roomId = roomRes.rows[0].id;

      const chatMemberRes = await client.query(
        `
        select crm.user_id
        from chat_room_members crm
        where crm.room_id = $1
          and crm.user_id = $2
        `,
        [roomId, userId]
      );

      if (chatMemberRes.rowCount === 0) {
        await client.query("rollback");
        return fail(res, 403, "chat room member not found");
      }

      const insertRes = await client.query(
        `
        insert into chat_messages (
          room_id,
          sender_id,
          content
        )
        values ($1, $2, $3)
        returning
          id,
          room_id,
          sender_id,
          content,
          created_at,
          updated_at
        `,
        [roomId, userId, content]
      );

      const message = insertRes.rows[0];

      const senderRes = await client.query(
        `
        select
          up.nickname,
          up.profile_image_url
        from users u
        left join user_profiles up
          on up.user_id = u.id
        where u.id = $1
        `,
        [userId]
      );

      await client.query("commit");

      return ok(
        res,
        {
          item: {
            id: Number(message.id),
            roomId: Number(message.room_id),
            senderId: Number(message.sender_id),
            senderNickname: senderRes.rows[0]?.nickname ?? null,
            senderProfileImageUrl:
              senderRes.rows[0]?.profile_image_url ?? null,
            content: message.content,
            createdAt: message.created_at,
            updatedAt: message.updated_at,
          },
        },
        201
      );
    } catch (error: any) {
      await client.query("rollback");
      console.error("POST /chat/meetings/:meetingId/messages error:", error);
      return fail(res, 500, "failed to send chat message");
    } finally {
      client.release();
    }
  }
);


export default router;
