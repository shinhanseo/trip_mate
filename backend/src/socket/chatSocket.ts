import http from "node:http";
import { Server, Socket } from "socket.io";
import { pool } from "../db";
import { AuthUser, verifyAccessToken } from "../middleware/authRequired";

type JoinRoomPayload = {
  meetingId: number;
};

type SendMessagePayload = {
  meetingId: number;
  content: string;
};

type SocketErrorPayload = {
  message: string;
}

type NewMessagePayload = {
  id: number;
  roomId: number;
  meetingId: number;
  type: "text" | "system",
  senderId: number | null;
  senderNickname: string | null;
  senderProfileImageUrl: string | null;
  content: string;
  createdAt: string;
  updatedAt: string;
  unreadCount: number;
};

type AuthedSocket = Socket & {
  data: {
    user: AuthUser;
  };
};

function getRoomName(meetingId: number) {
  return `meeting:${meetingId}`;
}

export function setupChatSocket(server: http.Server) {
  const io = new Server(server, {
    cors: {
      origin: true,
      credentials: true,
    },
    transports: ["websocket"],
  });

  io.use((socket, next) => {
    try {
      const token = socket.handshake.auth?.token;

      if (!token || typeof token !== "string") {
        return next(new Error("access token required"));
      }

      const user = verifyAccessToken(token);
      (socket as AuthedSocket).data.user = user;

      next();
    } catch {
      next(new Error("invalid or expired access token"));
    }
  });

  io.on("connection", (socket) => {
    const authedSocket = socket as AuthedSocket;
    const userId = authedSocket.data.user.userId;

    socket.on("join_room", async (payload: JoinRoomPayload) => {
      const meetingId = Number(payload?.meetingId);

      console.log("join_room", { userId, meetingId });

      if (!Number.isInteger(meetingId) || meetingId <= 0) {
        socket.emit("socket_error", {
          message: "invalid meeting id",
        } satisfies SocketErrorPayload);
        return;
      }

      const client = await pool.connect();

      try {
        await client.query("begin");

        const memberRes = await client.query(
          `
          select
            cr.id as room_id,
            crm.id as chat_room_member_id,
            crm.join_notice_sent,
            up.nickname
          from chat_rooms cr
          join chat_room_members crm
            on crm.room_id = cr.id
           and crm.user_id = $2
          left join user_profiles up
            on up.user_id = crm.user_id
          where cr.meeting_id = $1
          for update of crm
          `,
          [meetingId, userId]
        );

        if (memberRes.rowCount === 0) {
          await client.query("rollback");
          socket.emit("socket_error", {
            message: "forbidden",
          } satisfies SocketErrorPayload);
          return;
        }

        const member = memberRes.rows[0];
        const roomId = Number(member.room_id);
        const chatRoomMemberId = member.chat_room_member_id;
        const joinNoticeSent = Boolean(member.join_notice_sent);
        const nickname = member.nickname ?? "새로운 동행자";

        let systemMessage: NewMessagePayload | null = null;

        if (!joinNoticeSent) {
          const insertMessageRes = await client.query(
            `
            insert into chat_messages (
              room_id,
              sender_id,
              content,
              message_type
            )
            values ($1, null, $2, 'system')
            returning
              id,
              room_id,
              sender_id,
              content,
              message_type,
              created_at,
              updated_at
            `,
            [roomId, `${nickname}님이 동행에 참가했어요`]
          );

          await client.query(
            `
            update chat_room_members
            set join_notice_sent = true
            where id = $1
            `,
            [chatRoomMemberId]
          );

          const message = insertMessageRes.rows[0];

          systemMessage = {
            id: Number(message.id),
            roomId: Number(message.room_id),
            meetingId,
            type: message.message_type,
            senderId: message.sender_id === null ? null : Number(message.sender_id),
            senderNickname: null,
            senderProfileImageUrl: null,
            content: message.content,
            createdAt: new Date(message.created_at).toISOString(),
            updatedAt: new Date(message.updated_at).toISOString(),
            unreadCount: 0,
          };
        }

        await client.query("commit");

        const roomName = getRoomName(meetingId);

        await socket.join(roomName);

        console.log("joined_room_done", { userId, roomName });

        socket.emit("joined_room", {
          meetingId,
          roomName,
        });

        if (systemMessage) {
          io.to(roomName).emit("new_message", systemMessage);
        }
      } catch (error) {
        await client.query("rollback");

        console.error("join_room error:", error);

        socket.emit("socket_error", {
          message: "failed to join room",
        } satisfies SocketErrorPayload);
      } finally {
        client.release();
      }
    });


    socket.on("send_message", async (payload: SendMessagePayload) => {
      const meetingId = Number(payload?.meetingId);
      const content =
        typeof payload?.content === "string" ? payload.content.trim() : "";

      console.log("send_message_received", { userId, meetingId, content });

      if (!Number.isInteger(meetingId) || meetingId <= 0) {
        socket.emit("socket_error", {
          message: "invalid meeting id",
        } satisfies SocketErrorPayload);
        return;
      }

      if (!content) {
        socket.emit("socket_error", {
          message: "content is required",
        } satisfies SocketErrorPayload);
        return;
      }

      if (content.length > 1000) {
        socket.emit("socket_error", {
          message: "content is too long",
        } satisfies SocketErrorPayload);
        return;
      }

      const client = await pool.connect();

      try {
        await client.query("begin");

        const roomRes = await client.query(
          `
          select cr.id as room_id
          from chat_rooms cr
          join chat_room_members crm
            on crm.room_id = cr.id
           and crm.user_id = $2
          where cr.meeting_id = $1
          for update
          `,
          [meetingId, userId]
        );

        if (roomRes.rowCount === 0) {
          await client.query("rollback");
          socket.emit("socket_error", {
            message: "chat room member not found",
          } satisfies SocketErrorPayload);
          return;
        }

        const roomId = roomRes.rows[0].room_id;

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

        const unreadCountRes = await client.query(
          `
          select count(*) as unread_count
          from chat_room_members
          where room_id = $1
            and user_id <> $2
            and joined_at <= $3
          `,
          [roomId, userId, insertRes.rows[0].created_at]
        );

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

        const message = insertRes.rows[0];
        const roomName = getRoomName(meetingId);

        console.log("message_inserted", { messageId: message.id, roomId });

        const newMessage: NewMessagePayload = {
          id: Number(message.id),
          roomId: Number(message.room_id),
          meetingId,
          type: "text",
          senderId: Number(message.sender_id),
          senderNickname: senderRes.rows[0]?.nickname ?? null,
          senderProfileImageUrl:
            senderRes.rows[0]?.profile_image_url ?? null,
          content: message.content,
          createdAt: new Date(message.created_at).toISOString(),
          updatedAt: new Date(message.updated_at).toISOString(),
          unreadCount: Number(unreadCountRes.rows[0]?.unread_count ?? 0),
        };

        console.log("emit_new_message", { roomName, messageId: message.id });
        io.to(roomName).emit("new_message", newMessage);

      } catch (error) {
        await client.query("rollback");
        console.error("send_message error:", error);
        socket.emit("socket_error", {
          message: "failed to send message",
        } satisfies SocketErrorPayload);
      } finally {
        client.release();
      }

    });

    socket.on("disconnect", () => {
      console.log("socket disconnected:", socket.id, "userId:", userId);
    });

  });
}