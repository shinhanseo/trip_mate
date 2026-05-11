import { Router, Response } from "express";
import { pool } from "../db";
import { authRequired, AuthRequest } from "../middleware/authRequired";
import { ok, fail } from "../utils/response";

const router = Router();

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
      const roomMemberRes = await client.query(
        `
        select
          cr.id as room_id,
          crm.joined_at,
          m.id as meeting_id,
          m.host_user_id,
          m.title,
          m.place_text,
          m.scheduled_at,
          m.max_members,
          m.status,
          count(mm.id) filter (where mm.status = 'joined') as current_members
        from chat_rooms cr
        join chat_room_members crm
          on crm.room_id = cr.id
         and crm.user_id = $2
        join meetings m
          on m.id = cr.meeting_id
        left join meeting_members mm
          on mm.meeting_id = m.id
        where cr.meeting_id = $1
        group by
          cr.id,
          crm.joined_at,
          m.id
        `,
        [meetingId, userId]
      );

      if (roomMemberRes.rowCount === 0) {
        return fail(res, 403, "forbidden");
      }

      const room = roomMemberRes.rows[0];
      const roomId = room.room_id;
      const joinedAt = room.joined_at;

      const messageRes = await client.query(
        `
        select
          cm.id,
          cm.room_id,
          cm.sender_id,
          coalesce(cm.message_type, 'text') as message_type,
          cm.content,
          cm.created_at,
          cm.updated_at,
          up.nickname as sender_nickname,
          up.profile_image_url as sender_profile_image_url,
          case
            when cm.sender_id is null then 0
            else (
              select count(*)
              from chat_room_members readers
              where readers.room_id = cm.room_id
                and readers.user_id <> cm.sender_id
                and readers.joined_at <= cm.created_at
                and (
                  readers.last_read_message_id is null
                  or readers.last_read_message_id < cm.id
                )
            )
          end as unread_count
        from chat_messages cm
        left join users u
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
        item: {
          roomId: Number(room.room_id),
          meeting: {
            id: Number(room.meeting_id),
            hostUserId: Number(room.host_user_id),
            title: room.title,
            placeText: room.place_text,
            scheduledAt: room.scheduled_at,
            maxMembers: Number(room.max_members),
            currentMembers: Number(room.current_members),
            status: room.status,
          },
          messages: messageRes.rows.map((row) => ({
            id: Number(row.id),
            roomId: Number(row.room_id),
            type: row.message_type ?? "text",
            senderId: row.sender_id === null ? null : Number(row.sender_id),
            senderNickname: row.sender_nickname,
            senderProfileImageUrl: row.sender_profile_image_url,
            content: row.content,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
            unreadCount: Number(row.unread_count),
          })),
        },
      });
    } catch (error: any) {
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
          content,
          message_type
        )
        values ($1, $2, $3, 'text')
        returning
          id,
          room_id,
          sender_id,
          message_type,
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
            type: message.message_type ?? "text",
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

router.get("/rooms", authRequired, async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;

  const client = await pool.connect();

  try {
    const roomRes = await client.query(
      `
      select
        cr.id as room_id,
        cr.meeting_id,
        cr.created_at as room_created_at,
        cr.updated_at as room_updated_at,
        crm.joined_at as chat_joined_at,
        m.title as meeting_title,
        m.place_text,
        m.scheduled_at,
        m.status as meeting_status,
        lm.id as last_message_id,
        lm.sender_id as last_message_sender_id,
        lm.message_type as last_message_type,
        lm.content as last_message_content,
        lm.created_at as last_message_created_at,
        up.nickname as last_message_sender_nickname,
        (
          select count(*)
          from chat_messages unread_cm
          where unread_cm.room_id = cr.id
            and unread_cm.created_at >= crm.joined_at
            and unread_cm.sender_id is not null
            and unread_cm.sender_id <> $1
            and (
              crm.last_read_message_id is null
              or unread_cm.id > crm.last_read_message_id
            )
        ) as unread_count
      from chat_room_members crm
      join chat_rooms cr
        on cr.id = crm.room_id
      join meetings m
        on m.id = cr.meeting_id
      left join lateral (
        select
          cm.id,
          cm.sender_id,
          coalesce(cm.message_type, 'text') as message_type,
          cm.content,
          cm.created_at
        from chat_messages cm
        where cm.room_id = cr.id
          and cm.created_at >= crm.joined_at
        order by cm.created_at desc, cm.id desc
        limit 1
      ) lm on true
      left join user_profiles up
        on up.user_id = lm.sender_id
      where crm.user_id = $1
        and m.status <> 'cancelled'
      order by
        coalesce(lm.created_at, cr.updated_at) desc,
        cr.id desc
      `,
      [userId]
    );

    return ok(res, {
      items: roomRes.rows.map((row) => ({
        roomId: Number(row.room_id),
        meetingId: Number(row.meeting_id),
        meetingTitle: row.meeting_title,
        placeText: row.place_text,
        scheduledAt: row.scheduled_at,
        meetingStatus: row.meeting_status,
        chatJoinedAt: row.chat_joined_at,
        roomCreatedAt: row.room_created_at,
        roomUpdatedAt: row.room_updated_at,
        lastMessageId:
          row.last_message_id === null ? null : Number(row.last_message_id),
        lastMessageSenderId:
          row.last_message_sender_id === null
            ? null
            : Number(row.last_message_sender_id),
        lastMessageType: row.last_message_type ?? null,
        lastMessageSenderNickname: row.last_message_sender_nickname,
        lastMessageContent: row.last_message_content,
        lastMessageCreatedAt: row.last_message_created_at,
        unreadCount: Number(row.unread_count),
      })),
    });
  } catch (error: any) {
    console.error("GET /chat/rooms error:", error);
    return fail(res, 500, "failed to load chat rooms");
  } finally {
    client.release();
  }
});

export default router;
