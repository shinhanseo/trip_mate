import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class ChatRoomsCache extends Table {
  IntColumn get roomId => integer()();

  IntColumn get meetingId => integer()();

  TextColumn get meetingTitle => text()();

  TextColumn get placeText => text()();

  DateTimeColumn get scheduledAt => dateTime()();

  TextColumn get meetingStatus => text()();

  DateTimeColumn get chatJoinedAt => dateTime()();

  DateTimeColumn get roomCreatedAt => dateTime()();

  DateTimeColumn get roomUpdatedAt => dateTime()();

  IntColumn get lastMessageId => integer().nullable()();

  IntColumn get lastMessageSenderId => integer().nullable()();

  TextColumn get lastMessageSenderNickname => text().nullable()();

  TextColumn get lastMessageContent => text().nullable()();

  DateTimeColumn get lastMessageCreatedAt => dateTime().nullable()();

  IntColumn get unreadCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {roomId};
}

class ChatMessagesCache extends Table {
  IntColumn get id => integer()();

  IntColumn get roomId => integer()();

  IntColumn get meetingId => integer()();

  TextColumn get type => text().withDefault(const Constant('text'))();

  IntColumn get senderId => integer().nullable()();

  TextColumn get senderNickname => text().nullable()();

  TextColumn get senderProfileImageUrl => text().nullable()();

  TextColumn get content => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get unreadCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ChatRoomsCache, ChatMessagesCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'tripmate.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
