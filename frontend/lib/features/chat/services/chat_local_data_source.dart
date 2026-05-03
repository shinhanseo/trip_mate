import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../models/chat_detail_model.dart';
import '../models/chat_list_model.dart';

class ChatLocalDataSource {
  final AppDatabase db;

  ChatLocalDataSource({required this.db});

  Future<void> saveChatRoomList(List<ChatListModel> rooms) async {
    final now = DateTime.now();

    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.chatRoomsCache,
        rooms.map((room) {
          return ChatRoomsCacheCompanion.insert(
            roomId: Value(room.roomId),
            meetingId: room.meetingId,
            meetingTitle: room.meetingTitle,
            placeText: room.placeText,
            scheduledAt: room.scheduledAt,
            meetingStatus: room.meetingStatus,
            chatJoinedAt: room.chatJoinedAt,
            roomCreatedAt: room.roomCreatedAt,
            roomUpdatedAt: room.roomUpdatedAt,
            lastMessageId: Value(room.lastMessageId),
            lastMessageSenderId: Value(room.lastMessageSenderId),
            lastMessageSenderNickname: Value(room.lastMessageSenderNickname),
            lastMessageContent: Value(room.lastMessageContent),
            lastMessageCreatedAt: Value(room.lastMessageCreatedAt),
            unreadCount: Value(room.unreadCount),
            syncedAt: now,
          );
        }).toList(),
      );
    });
  }

  Future<List<ChatListModel>> getChatRoomList() async {
    final rows =
        await (db.select(db.chatRoomsCache)..orderBy([
              (table) => OrderingTerm(
                expression: table.lastMessageCreatedAt,
                mode: OrderingMode.desc,
              ),
              (table) => OrderingTerm(
                expression: table.roomUpdatedAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();

    return rows.map((row) {
      return ChatListModel(
        roomId: row.roomId,
        meetingId: row.meetingId,
        meetingTitle: row.meetingTitle,
        placeText: row.placeText,
        scheduledAt: row.scheduledAt,
        meetingStatus: row.meetingStatus,
        chatJoinedAt: row.chatJoinedAt,
        roomCreatedAt: row.roomCreatedAt,
        roomUpdatedAt: row.roomUpdatedAt,
        lastMessageId: row.lastMessageId,
        lastMessageSenderId: row.lastMessageSenderId,
        lastMessageSenderNickname: row.lastMessageSenderNickname,
        lastMessageContent: row.lastMessageContent,
        lastMessageCreatedAt: row.lastMessageCreatedAt,
        unreadCount: row.unreadCount,
      );
    }).toList();
  }

  Future<void> saveChatDetail({
    required int meetingId,
    required ChatDetailModel detail,
  }) async {
    final now = DateTime.now();

    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.chatMessagesCache,
        detail.messages.map((message) {
          return ChatMessagesCacheCompanion.insert(
            id: Value(message.id),
            roomId: message.roomId,
            meetingId: meetingId,
            type: Value(message.type),
            senderId: Value(message.senderId),
            senderNickname: Value(message.senderNickname),
            senderProfileImageUrl: Value(message.senderProfileImageUrl),
            content: message.content,
            createdAt: message.createdAt,
            updatedAt: message.updatedAt,
            unreadCount: Value(message.unreadCount),
            syncedAt: now,
          );
        }).toList(),
      );
    });
  }

  Future<List<MessageModel>> getMessagesByMeetingId(int meetingId) async {
    final rows =
        await (db.select(db.chatMessagesCache)
              ..where((table) => table.meetingId.equals(meetingId))
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.createdAt,
                  mode: OrderingMode.asc,
                ),
                (table) =>
                    OrderingTerm(expression: table.id, mode: OrderingMode.asc),
              ]))
            .get();

    return rows.map((row) {
      return MessageModel(
        id: row.id,
        roomId: row.roomId,
        type: row.type,
        senderId: row.senderId,
        senderNickname: row.senderNickname,
        senderProfileImageUrl: row.senderProfileImageUrl,
        content: row.content,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        unreadCount: row.unreadCount,
      );
    }).toList();
  }

  Future<void> saveMessage({
    required int meetingId,
    required MessageModel message,
  }) async {
    await db
        .into(db.chatMessagesCache)
        .insertOnConflictUpdate(
          ChatMessagesCacheCompanion.insert(
            id: Value(message.id),
            roomId: message.roomId,
            meetingId: meetingId,
            type: Value(message.type),
            senderId: Value(message.senderId),
            senderNickname: Value(message.senderNickname),
            senderProfileImageUrl: Value(message.senderProfileImageUrl),
            content: message.content,
            createdAt: message.createdAt,
            updatedAt: message.updatedAt,
            unreadCount: Value(message.unreadCount),
            syncedAt: DateTime.now(),
          ),
        );
  }
}
