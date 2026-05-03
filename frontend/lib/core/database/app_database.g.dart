// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChatRoomsCacheTable extends ChatRoomsCache
    with TableInfo<$ChatRoomsCacheTable, ChatRoomsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatRoomsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<int> meetingId = GeneratedColumn<int>(
    'meeting_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meetingTitleMeta = const VerificationMeta(
    'meetingTitle',
  );
  @override
  late final GeneratedColumn<String> meetingTitle = GeneratedColumn<String>(
    'meeting_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeTextMeta = const VerificationMeta(
    'placeText',
  );
  @override
  late final GeneratedColumn<String> placeText = GeneratedColumn<String>(
    'place_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meetingStatusMeta = const VerificationMeta(
    'meetingStatus',
  );
  @override
  late final GeneratedColumn<String> meetingStatus = GeneratedColumn<String>(
    'meeting_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatJoinedAtMeta = const VerificationMeta(
    'chatJoinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> chatJoinedAt = GeneratedColumn<DateTime>(
    'chat_joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomCreatedAtMeta = const VerificationMeta(
    'roomCreatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> roomCreatedAt =
      GeneratedColumn<DateTime>(
        'room_created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _roomUpdatedAtMeta = const VerificationMeta(
    'roomUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> roomUpdatedAt =
      GeneratedColumn<DateTime>(
        'room_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastMessageIdMeta = const VerificationMeta(
    'lastMessageId',
  );
  @override
  late final GeneratedColumn<int> lastMessageId = GeneratedColumn<int>(
    'last_message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageSenderIdMeta =
      const VerificationMeta('lastMessageSenderId');
  @override
  late final GeneratedColumn<int> lastMessageSenderId = GeneratedColumn<int>(
    'last_message_sender_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageSenderNicknameMeta =
      const VerificationMeta('lastMessageSenderNickname');
  @override
  late final GeneratedColumn<String> lastMessageSenderNickname =
      GeneratedColumn<String>(
        'last_message_sender_nickname',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastMessageContentMeta =
      const VerificationMeta('lastMessageContent');
  @override
  late final GeneratedColumn<String> lastMessageContent =
      GeneratedColumn<String>(
        'last_message_content',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastMessageCreatedAtMeta =
      const VerificationMeta('lastMessageCreatedAt');
  @override
  late final GeneratedColumn<DateTime> lastMessageCreatedAt =
      GeneratedColumn<DateTime>(
        'last_message_created_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    roomId,
    meetingId,
    meetingTitle,
    placeText,
    scheduledAt,
    meetingStatus,
    chatJoinedAt,
    roomCreatedAt,
    roomUpdatedAt,
    lastMessageId,
    lastMessageSenderId,
    lastMessageSenderNickname,
    lastMessageContent,
    lastMessageCreatedAt,
    unreadCount,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_rooms_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatRoomsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    }
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_meetingIdMeta);
    }
    if (data.containsKey('meeting_title')) {
      context.handle(
        _meetingTitleMeta,
        meetingTitle.isAcceptableOrUnknown(
          data['meeting_title']!,
          _meetingTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meetingTitleMeta);
    }
    if (data.containsKey('place_text')) {
      context.handle(
        _placeTextMeta,
        placeText.isAcceptableOrUnknown(data['place_text']!, _placeTextMeta),
      );
    } else if (isInserting) {
      context.missing(_placeTextMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('meeting_status')) {
      context.handle(
        _meetingStatusMeta,
        meetingStatus.isAcceptableOrUnknown(
          data['meeting_status']!,
          _meetingStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meetingStatusMeta);
    }
    if (data.containsKey('chat_joined_at')) {
      context.handle(
        _chatJoinedAtMeta,
        chatJoinedAt.isAcceptableOrUnknown(
          data['chat_joined_at']!,
          _chatJoinedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chatJoinedAtMeta);
    }
    if (data.containsKey('room_created_at')) {
      context.handle(
        _roomCreatedAtMeta,
        roomCreatedAt.isAcceptableOrUnknown(
          data['room_created_at']!,
          _roomCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roomCreatedAtMeta);
    }
    if (data.containsKey('room_updated_at')) {
      context.handle(
        _roomUpdatedAtMeta,
        roomUpdatedAt.isAcceptableOrUnknown(
          data['room_updated_at']!,
          _roomUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roomUpdatedAtMeta);
    }
    if (data.containsKey('last_message_id')) {
      context.handle(
        _lastMessageIdMeta,
        lastMessageId.isAcceptableOrUnknown(
          data['last_message_id']!,
          _lastMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_sender_id')) {
      context.handle(
        _lastMessageSenderIdMeta,
        lastMessageSenderId.isAcceptableOrUnknown(
          data['last_message_sender_id']!,
          _lastMessageSenderIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_sender_nickname')) {
      context.handle(
        _lastMessageSenderNicknameMeta,
        lastMessageSenderNickname.isAcceptableOrUnknown(
          data['last_message_sender_nickname']!,
          _lastMessageSenderNicknameMeta,
        ),
      );
    }
    if (data.containsKey('last_message_content')) {
      context.handle(
        _lastMessageContentMeta,
        lastMessageContent.isAcceptableOrUnknown(
          data['last_message_content']!,
          _lastMessageContentMeta,
        ),
      );
    }
    if (data.containsKey('last_message_created_at')) {
      context.handle(
        _lastMessageCreatedAtMeta,
        lastMessageCreatedAt.isAcceptableOrUnknown(
          data['last_message_created_at']!,
          _lastMessageCreatedAtMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomId};
  @override
  ChatRoomsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRoomsCacheData(
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}room_id'],
      )!,
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meeting_id'],
      )!,
      meetingTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_title'],
      )!,
      placeText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_text'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      meetingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_status'],
      )!,
      chatJoinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}chat_joined_at'],
      )!,
      roomCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}room_created_at'],
      )!,
      roomUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}room_updated_at'],
      )!,
      lastMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_id'],
      ),
      lastMessageSenderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_sender_id'],
      ),
      lastMessageSenderNickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_sender_nickname'],
      ),
      lastMessageContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_content'],
      ),
      lastMessageCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_created_at'],
      ),
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $ChatRoomsCacheTable createAlias(String alias) {
    return $ChatRoomsCacheTable(attachedDatabase, alias);
  }
}

class ChatRoomsCacheData extends DataClass
    implements Insertable<ChatRoomsCacheData> {
  final int roomId;
  final int meetingId;
  final String meetingTitle;
  final String placeText;
  final DateTime scheduledAt;
  final String meetingStatus;
  final DateTime chatJoinedAt;
  final DateTime roomCreatedAt;
  final DateTime roomUpdatedAt;
  final int? lastMessageId;
  final int? lastMessageSenderId;
  final String? lastMessageSenderNickname;
  final String? lastMessageContent;
  final DateTime? lastMessageCreatedAt;
  final int unreadCount;
  final DateTime syncedAt;
  const ChatRoomsCacheData({
    required this.roomId,
    required this.meetingId,
    required this.meetingTitle,
    required this.placeText,
    required this.scheduledAt,
    required this.meetingStatus,
    required this.chatJoinedAt,
    required this.roomCreatedAt,
    required this.roomUpdatedAt,
    this.lastMessageId,
    this.lastMessageSenderId,
    this.lastMessageSenderNickname,
    this.lastMessageContent,
    this.lastMessageCreatedAt,
    required this.unreadCount,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['room_id'] = Variable<int>(roomId);
    map['meeting_id'] = Variable<int>(meetingId);
    map['meeting_title'] = Variable<String>(meetingTitle);
    map['place_text'] = Variable<String>(placeText);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['meeting_status'] = Variable<String>(meetingStatus);
    map['chat_joined_at'] = Variable<DateTime>(chatJoinedAt);
    map['room_created_at'] = Variable<DateTime>(roomCreatedAt);
    map['room_updated_at'] = Variable<DateTime>(roomUpdatedAt);
    if (!nullToAbsent || lastMessageId != null) {
      map['last_message_id'] = Variable<int>(lastMessageId);
    }
    if (!nullToAbsent || lastMessageSenderId != null) {
      map['last_message_sender_id'] = Variable<int>(lastMessageSenderId);
    }
    if (!nullToAbsent || lastMessageSenderNickname != null) {
      map['last_message_sender_nickname'] = Variable<String>(
        lastMessageSenderNickname,
      );
    }
    if (!nullToAbsent || lastMessageContent != null) {
      map['last_message_content'] = Variable<String>(lastMessageContent);
    }
    if (!nullToAbsent || lastMessageCreatedAt != null) {
      map['last_message_created_at'] = Variable<DateTime>(lastMessageCreatedAt);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  ChatRoomsCacheCompanion toCompanion(bool nullToAbsent) {
    return ChatRoomsCacheCompanion(
      roomId: Value(roomId),
      meetingId: Value(meetingId),
      meetingTitle: Value(meetingTitle),
      placeText: Value(placeText),
      scheduledAt: Value(scheduledAt),
      meetingStatus: Value(meetingStatus),
      chatJoinedAt: Value(chatJoinedAt),
      roomCreatedAt: Value(roomCreatedAt),
      roomUpdatedAt: Value(roomUpdatedAt),
      lastMessageId: lastMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageId),
      lastMessageSenderId: lastMessageSenderId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageSenderId),
      lastMessageSenderNickname:
          lastMessageSenderNickname == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageSenderNickname),
      lastMessageContent: lastMessageContent == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageContent),
      lastMessageCreatedAt: lastMessageCreatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageCreatedAt),
      unreadCount: Value(unreadCount),
      syncedAt: Value(syncedAt),
    );
  }

  factory ChatRoomsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRoomsCacheData(
      roomId: serializer.fromJson<int>(json['roomId']),
      meetingId: serializer.fromJson<int>(json['meetingId']),
      meetingTitle: serializer.fromJson<String>(json['meetingTitle']),
      placeText: serializer.fromJson<String>(json['placeText']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      meetingStatus: serializer.fromJson<String>(json['meetingStatus']),
      chatJoinedAt: serializer.fromJson<DateTime>(json['chatJoinedAt']),
      roomCreatedAt: serializer.fromJson<DateTime>(json['roomCreatedAt']),
      roomUpdatedAt: serializer.fromJson<DateTime>(json['roomUpdatedAt']),
      lastMessageId: serializer.fromJson<int?>(json['lastMessageId']),
      lastMessageSenderId: serializer.fromJson<int?>(
        json['lastMessageSenderId'],
      ),
      lastMessageSenderNickname: serializer.fromJson<String?>(
        json['lastMessageSenderNickname'],
      ),
      lastMessageContent: serializer.fromJson<String?>(
        json['lastMessageContent'],
      ),
      lastMessageCreatedAt: serializer.fromJson<DateTime?>(
        json['lastMessageCreatedAt'],
      ),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<int>(roomId),
      'meetingId': serializer.toJson<int>(meetingId),
      'meetingTitle': serializer.toJson<String>(meetingTitle),
      'placeText': serializer.toJson<String>(placeText),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'meetingStatus': serializer.toJson<String>(meetingStatus),
      'chatJoinedAt': serializer.toJson<DateTime>(chatJoinedAt),
      'roomCreatedAt': serializer.toJson<DateTime>(roomCreatedAt),
      'roomUpdatedAt': serializer.toJson<DateTime>(roomUpdatedAt),
      'lastMessageId': serializer.toJson<int?>(lastMessageId),
      'lastMessageSenderId': serializer.toJson<int?>(lastMessageSenderId),
      'lastMessageSenderNickname': serializer.toJson<String?>(
        lastMessageSenderNickname,
      ),
      'lastMessageContent': serializer.toJson<String?>(lastMessageContent),
      'lastMessageCreatedAt': serializer.toJson<DateTime?>(
        lastMessageCreatedAt,
      ),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  ChatRoomsCacheData copyWith({
    int? roomId,
    int? meetingId,
    String? meetingTitle,
    String? placeText,
    DateTime? scheduledAt,
    String? meetingStatus,
    DateTime? chatJoinedAt,
    DateTime? roomCreatedAt,
    DateTime? roomUpdatedAt,
    Value<int?> lastMessageId = const Value.absent(),
    Value<int?> lastMessageSenderId = const Value.absent(),
    Value<String?> lastMessageSenderNickname = const Value.absent(),
    Value<String?> lastMessageContent = const Value.absent(),
    Value<DateTime?> lastMessageCreatedAt = const Value.absent(),
    int? unreadCount,
    DateTime? syncedAt,
  }) => ChatRoomsCacheData(
    roomId: roomId ?? this.roomId,
    meetingId: meetingId ?? this.meetingId,
    meetingTitle: meetingTitle ?? this.meetingTitle,
    placeText: placeText ?? this.placeText,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    meetingStatus: meetingStatus ?? this.meetingStatus,
    chatJoinedAt: chatJoinedAt ?? this.chatJoinedAt,
    roomCreatedAt: roomCreatedAt ?? this.roomCreatedAt,
    roomUpdatedAt: roomUpdatedAt ?? this.roomUpdatedAt,
    lastMessageId: lastMessageId.present
        ? lastMessageId.value
        : this.lastMessageId,
    lastMessageSenderId: lastMessageSenderId.present
        ? lastMessageSenderId.value
        : this.lastMessageSenderId,
    lastMessageSenderNickname: lastMessageSenderNickname.present
        ? lastMessageSenderNickname.value
        : this.lastMessageSenderNickname,
    lastMessageContent: lastMessageContent.present
        ? lastMessageContent.value
        : this.lastMessageContent,
    lastMessageCreatedAt: lastMessageCreatedAt.present
        ? lastMessageCreatedAt.value
        : this.lastMessageCreatedAt,
    unreadCount: unreadCount ?? this.unreadCount,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  ChatRoomsCacheData copyWithCompanion(ChatRoomsCacheCompanion data) {
    return ChatRoomsCacheData(
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      meetingTitle: data.meetingTitle.present
          ? data.meetingTitle.value
          : this.meetingTitle,
      placeText: data.placeText.present ? data.placeText.value : this.placeText,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      meetingStatus: data.meetingStatus.present
          ? data.meetingStatus.value
          : this.meetingStatus,
      chatJoinedAt: data.chatJoinedAt.present
          ? data.chatJoinedAt.value
          : this.chatJoinedAt,
      roomCreatedAt: data.roomCreatedAt.present
          ? data.roomCreatedAt.value
          : this.roomCreatedAt,
      roomUpdatedAt: data.roomUpdatedAt.present
          ? data.roomUpdatedAt.value
          : this.roomUpdatedAt,
      lastMessageId: data.lastMessageId.present
          ? data.lastMessageId.value
          : this.lastMessageId,
      lastMessageSenderId: data.lastMessageSenderId.present
          ? data.lastMessageSenderId.value
          : this.lastMessageSenderId,
      lastMessageSenderNickname: data.lastMessageSenderNickname.present
          ? data.lastMessageSenderNickname.value
          : this.lastMessageSenderNickname,
      lastMessageContent: data.lastMessageContent.present
          ? data.lastMessageContent.value
          : this.lastMessageContent,
      lastMessageCreatedAt: data.lastMessageCreatedAt.present
          ? data.lastMessageCreatedAt.value
          : this.lastMessageCreatedAt,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoomsCacheData(')
          ..write('roomId: $roomId, ')
          ..write('meetingId: $meetingId, ')
          ..write('meetingTitle: $meetingTitle, ')
          ..write('placeText: $placeText, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('meetingStatus: $meetingStatus, ')
          ..write('chatJoinedAt: $chatJoinedAt, ')
          ..write('roomCreatedAt: $roomCreatedAt, ')
          ..write('roomUpdatedAt: $roomUpdatedAt, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessageSenderId: $lastMessageSenderId, ')
          ..write('lastMessageSenderNickname: $lastMessageSenderNickname, ')
          ..write('lastMessageContent: $lastMessageContent, ')
          ..write('lastMessageCreatedAt: $lastMessageCreatedAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    roomId,
    meetingId,
    meetingTitle,
    placeText,
    scheduledAt,
    meetingStatus,
    chatJoinedAt,
    roomCreatedAt,
    roomUpdatedAt,
    lastMessageId,
    lastMessageSenderId,
    lastMessageSenderNickname,
    lastMessageContent,
    lastMessageCreatedAt,
    unreadCount,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRoomsCacheData &&
          other.roomId == this.roomId &&
          other.meetingId == this.meetingId &&
          other.meetingTitle == this.meetingTitle &&
          other.placeText == this.placeText &&
          other.scheduledAt == this.scheduledAt &&
          other.meetingStatus == this.meetingStatus &&
          other.chatJoinedAt == this.chatJoinedAt &&
          other.roomCreatedAt == this.roomCreatedAt &&
          other.roomUpdatedAt == this.roomUpdatedAt &&
          other.lastMessageId == this.lastMessageId &&
          other.lastMessageSenderId == this.lastMessageSenderId &&
          other.lastMessageSenderNickname == this.lastMessageSenderNickname &&
          other.lastMessageContent == this.lastMessageContent &&
          other.lastMessageCreatedAt == this.lastMessageCreatedAt &&
          other.unreadCount == this.unreadCount &&
          other.syncedAt == this.syncedAt);
}

class ChatRoomsCacheCompanion extends UpdateCompanion<ChatRoomsCacheData> {
  final Value<int> roomId;
  final Value<int> meetingId;
  final Value<String> meetingTitle;
  final Value<String> placeText;
  final Value<DateTime> scheduledAt;
  final Value<String> meetingStatus;
  final Value<DateTime> chatJoinedAt;
  final Value<DateTime> roomCreatedAt;
  final Value<DateTime> roomUpdatedAt;
  final Value<int?> lastMessageId;
  final Value<int?> lastMessageSenderId;
  final Value<String?> lastMessageSenderNickname;
  final Value<String?> lastMessageContent;
  final Value<DateTime?> lastMessageCreatedAt;
  final Value<int> unreadCount;
  final Value<DateTime> syncedAt;
  const ChatRoomsCacheCompanion({
    this.roomId = const Value.absent(),
    this.meetingId = const Value.absent(),
    this.meetingTitle = const Value.absent(),
    this.placeText = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.meetingStatus = const Value.absent(),
    this.chatJoinedAt = const Value.absent(),
    this.roomCreatedAt = const Value.absent(),
    this.roomUpdatedAt = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.lastMessageSenderId = const Value.absent(),
    this.lastMessageSenderNickname = const Value.absent(),
    this.lastMessageContent = const Value.absent(),
    this.lastMessageCreatedAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  ChatRoomsCacheCompanion.insert({
    this.roomId = const Value.absent(),
    required int meetingId,
    required String meetingTitle,
    required String placeText,
    required DateTime scheduledAt,
    required String meetingStatus,
    required DateTime chatJoinedAt,
    required DateTime roomCreatedAt,
    required DateTime roomUpdatedAt,
    this.lastMessageId = const Value.absent(),
    this.lastMessageSenderId = const Value.absent(),
    this.lastMessageSenderNickname = const Value.absent(),
    this.lastMessageContent = const Value.absent(),
    this.lastMessageCreatedAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    required DateTime syncedAt,
  }) : meetingId = Value(meetingId),
       meetingTitle = Value(meetingTitle),
       placeText = Value(placeText),
       scheduledAt = Value(scheduledAt),
       meetingStatus = Value(meetingStatus),
       chatJoinedAt = Value(chatJoinedAt),
       roomCreatedAt = Value(roomCreatedAt),
       roomUpdatedAt = Value(roomUpdatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<ChatRoomsCacheData> custom({
    Expression<int>? roomId,
    Expression<int>? meetingId,
    Expression<String>? meetingTitle,
    Expression<String>? placeText,
    Expression<DateTime>? scheduledAt,
    Expression<String>? meetingStatus,
    Expression<DateTime>? chatJoinedAt,
    Expression<DateTime>? roomCreatedAt,
    Expression<DateTime>? roomUpdatedAt,
    Expression<int>? lastMessageId,
    Expression<int>? lastMessageSenderId,
    Expression<String>? lastMessageSenderNickname,
    Expression<String>? lastMessageContent,
    Expression<DateTime>? lastMessageCreatedAt,
    Expression<int>? unreadCount,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (meetingId != null) 'meeting_id': meetingId,
      if (meetingTitle != null) 'meeting_title': meetingTitle,
      if (placeText != null) 'place_text': placeText,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (meetingStatus != null) 'meeting_status': meetingStatus,
      if (chatJoinedAt != null) 'chat_joined_at': chatJoinedAt,
      if (roomCreatedAt != null) 'room_created_at': roomCreatedAt,
      if (roomUpdatedAt != null) 'room_updated_at': roomUpdatedAt,
      if (lastMessageId != null) 'last_message_id': lastMessageId,
      if (lastMessageSenderId != null)
        'last_message_sender_id': lastMessageSenderId,
      if (lastMessageSenderNickname != null)
        'last_message_sender_nickname': lastMessageSenderNickname,
      if (lastMessageContent != null)
        'last_message_content': lastMessageContent,
      if (lastMessageCreatedAt != null)
        'last_message_created_at': lastMessageCreatedAt,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  ChatRoomsCacheCompanion copyWith({
    Value<int>? roomId,
    Value<int>? meetingId,
    Value<String>? meetingTitle,
    Value<String>? placeText,
    Value<DateTime>? scheduledAt,
    Value<String>? meetingStatus,
    Value<DateTime>? chatJoinedAt,
    Value<DateTime>? roomCreatedAt,
    Value<DateTime>? roomUpdatedAt,
    Value<int?>? lastMessageId,
    Value<int?>? lastMessageSenderId,
    Value<String?>? lastMessageSenderNickname,
    Value<String?>? lastMessageContent,
    Value<DateTime?>? lastMessageCreatedAt,
    Value<int>? unreadCount,
    Value<DateTime>? syncedAt,
  }) {
    return ChatRoomsCacheCompanion(
      roomId: roomId ?? this.roomId,
      meetingId: meetingId ?? this.meetingId,
      meetingTitle: meetingTitle ?? this.meetingTitle,
      placeText: placeText ?? this.placeText,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      meetingStatus: meetingStatus ?? this.meetingStatus,
      chatJoinedAt: chatJoinedAt ?? this.chatJoinedAt,
      roomCreatedAt: roomCreatedAt ?? this.roomCreatedAt,
      roomUpdatedAt: roomUpdatedAt ?? this.roomUpdatedAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageSenderNickname:
          lastMessageSenderNickname ?? this.lastMessageSenderNickname,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageCreatedAt: lastMessageCreatedAt ?? this.lastMessageCreatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (meetingId.present) {
      map['meeting_id'] = Variable<int>(meetingId.value);
    }
    if (meetingTitle.present) {
      map['meeting_title'] = Variable<String>(meetingTitle.value);
    }
    if (placeText.present) {
      map['place_text'] = Variable<String>(placeText.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (meetingStatus.present) {
      map['meeting_status'] = Variable<String>(meetingStatus.value);
    }
    if (chatJoinedAt.present) {
      map['chat_joined_at'] = Variable<DateTime>(chatJoinedAt.value);
    }
    if (roomCreatedAt.present) {
      map['room_created_at'] = Variable<DateTime>(roomCreatedAt.value);
    }
    if (roomUpdatedAt.present) {
      map['room_updated_at'] = Variable<DateTime>(roomUpdatedAt.value);
    }
    if (lastMessageId.present) {
      map['last_message_id'] = Variable<int>(lastMessageId.value);
    }
    if (lastMessageSenderId.present) {
      map['last_message_sender_id'] = Variable<int>(lastMessageSenderId.value);
    }
    if (lastMessageSenderNickname.present) {
      map['last_message_sender_nickname'] = Variable<String>(
        lastMessageSenderNickname.value,
      );
    }
    if (lastMessageContent.present) {
      map['last_message_content'] = Variable<String>(lastMessageContent.value);
    }
    if (lastMessageCreatedAt.present) {
      map['last_message_created_at'] = Variable<DateTime>(
        lastMessageCreatedAt.value,
      );
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoomsCacheCompanion(')
          ..write('roomId: $roomId, ')
          ..write('meetingId: $meetingId, ')
          ..write('meetingTitle: $meetingTitle, ')
          ..write('placeText: $placeText, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('meetingStatus: $meetingStatus, ')
          ..write('chatJoinedAt: $chatJoinedAt, ')
          ..write('roomCreatedAt: $roomCreatedAt, ')
          ..write('roomUpdatedAt: $roomUpdatedAt, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessageSenderId: $lastMessageSenderId, ')
          ..write('lastMessageSenderNickname: $lastMessageSenderNickname, ')
          ..write('lastMessageContent: $lastMessageContent, ')
          ..write('lastMessageCreatedAt: $lastMessageCreatedAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesCacheTable extends ChatMessagesCache
    with TableInfo<$ChatMessagesCacheTable, ChatMessagesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<int> meetingId = GeneratedColumn<int>(
    'meeting_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<int> senderId = GeneratedColumn<int>(
    'sender_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderNicknameMeta = const VerificationMeta(
    'senderNickname',
  );
  @override
  late final GeneratedColumn<String> senderNickname = GeneratedColumn<String>(
    'sender_nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderProfileImageUrlMeta =
      const VerificationMeta('senderProfileImageUrl');
  @override
  late final GeneratedColumn<String> senderProfileImageUrl =
      GeneratedColumn<String>(
        'sender_profile_image_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roomId,
    meetingId,
    type,
    senderId,
    senderNickname,
    senderProfileImageUrl,
    content,
    createdAt,
    updatedAt,
    unreadCount,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessagesCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_meetingIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    }
    if (data.containsKey('sender_nickname')) {
      context.handle(
        _senderNicknameMeta,
        senderNickname.isAcceptableOrUnknown(
          data['sender_nickname']!,
          _senderNicknameMeta,
        ),
      );
    }
    if (data.containsKey('sender_profile_image_url')) {
      context.handle(
        _senderProfileImageUrlMeta,
        senderProfileImageUrl.isAcceptableOrUnknown(
          data['sender_profile_image_url']!,
          _senderProfileImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessagesCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessagesCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}room_id'],
      )!,
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meeting_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sender_id'],
      ),
      senderNickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_nickname'],
      ),
      senderProfileImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_profile_image_url'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $ChatMessagesCacheTable createAlias(String alias) {
    return $ChatMessagesCacheTable(attachedDatabase, alias);
  }
}

class ChatMessagesCacheData extends DataClass
    implements Insertable<ChatMessagesCacheData> {
  final int id;
  final int roomId;
  final int meetingId;
  final String type;
  final int? senderId;
  final String? senderNickname;
  final String? senderProfileImageUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;
  final DateTime syncedAt;
  const ChatMessagesCacheData({
    required this.id,
    required this.roomId,
    required this.meetingId,
    required this.type,
    this.senderId,
    this.senderNickname,
    this.senderProfileImageUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['room_id'] = Variable<int>(roomId);
    map['meeting_id'] = Variable<int>(meetingId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || senderId != null) {
      map['sender_id'] = Variable<int>(senderId);
    }
    if (!nullToAbsent || senderNickname != null) {
      map['sender_nickname'] = Variable<String>(senderNickname);
    }
    if (!nullToAbsent || senderProfileImageUrl != null) {
      map['sender_profile_image_url'] = Variable<String>(senderProfileImageUrl);
    }
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['unread_count'] = Variable<int>(unreadCount);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  ChatMessagesCacheCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCacheCompanion(
      id: Value(id),
      roomId: Value(roomId),
      meetingId: Value(meetingId),
      type: Value(type),
      senderId: senderId == null && nullToAbsent
          ? const Value.absent()
          : Value(senderId),
      senderNickname: senderNickname == null && nullToAbsent
          ? const Value.absent()
          : Value(senderNickname),
      senderProfileImageUrl: senderProfileImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(senderProfileImageUrl),
      content: Value(content),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      unreadCount: Value(unreadCount),
      syncedAt: Value(syncedAt),
    );
  }

  factory ChatMessagesCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessagesCacheData(
      id: serializer.fromJson<int>(json['id']),
      roomId: serializer.fromJson<int>(json['roomId']),
      meetingId: serializer.fromJson<int>(json['meetingId']),
      type: serializer.fromJson<String>(json['type']),
      senderId: serializer.fromJson<int?>(json['senderId']),
      senderNickname: serializer.fromJson<String?>(json['senderNickname']),
      senderProfileImageUrl: serializer.fromJson<String?>(
        json['senderProfileImageUrl'],
      ),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roomId': serializer.toJson<int>(roomId),
      'meetingId': serializer.toJson<int>(meetingId),
      'type': serializer.toJson<String>(type),
      'senderId': serializer.toJson<int?>(senderId),
      'senderNickname': serializer.toJson<String?>(senderNickname),
      'senderProfileImageUrl': serializer.toJson<String?>(
        senderProfileImageUrl,
      ),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  ChatMessagesCacheData copyWith({
    int? id,
    int? roomId,
    int? meetingId,
    String? type,
    Value<int?> senderId = const Value.absent(),
    Value<String?> senderNickname = const Value.absent(),
    Value<String?> senderProfileImageUrl = const Value.absent(),
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? unreadCount,
    DateTime? syncedAt,
  }) => ChatMessagesCacheData(
    id: id ?? this.id,
    roomId: roomId ?? this.roomId,
    meetingId: meetingId ?? this.meetingId,
    type: type ?? this.type,
    senderId: senderId.present ? senderId.value : this.senderId,
    senderNickname: senderNickname.present
        ? senderNickname.value
        : this.senderNickname,
    senderProfileImageUrl: senderProfileImageUrl.present
        ? senderProfileImageUrl.value
        : this.senderProfileImageUrl,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    unreadCount: unreadCount ?? this.unreadCount,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  ChatMessagesCacheData copyWithCompanion(ChatMessagesCacheCompanion data) {
    return ChatMessagesCacheData(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      type: data.type.present ? data.type.value : this.type,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderNickname: data.senderNickname.present
          ? data.senderNickname.value
          : this.senderNickname,
      senderProfileImageUrl: data.senderProfileImageUrl.present
          ? data.senderProfileImageUrl.value
          : this.senderProfileImageUrl,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCacheData(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('meetingId: $meetingId, ')
          ..write('type: $type, ')
          ..write('senderId: $senderId, ')
          ..write('senderNickname: $senderNickname, ')
          ..write('senderProfileImageUrl: $senderProfileImageUrl, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roomId,
    meetingId,
    type,
    senderId,
    senderNickname,
    senderProfileImageUrl,
    content,
    createdAt,
    updatedAt,
    unreadCount,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessagesCacheData &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.meetingId == this.meetingId &&
          other.type == this.type &&
          other.senderId == this.senderId &&
          other.senderNickname == this.senderNickname &&
          other.senderProfileImageUrl == this.senderProfileImageUrl &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.unreadCount == this.unreadCount &&
          other.syncedAt == this.syncedAt);
}

class ChatMessagesCacheCompanion
    extends UpdateCompanion<ChatMessagesCacheData> {
  final Value<int> id;
  final Value<int> roomId;
  final Value<int> meetingId;
  final Value<String> type;
  final Value<int?> senderId;
  final Value<String?> senderNickname;
  final Value<String?> senderProfileImageUrl;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> unreadCount;
  final Value<DateTime> syncedAt;
  const ChatMessagesCacheCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.meetingId = const Value.absent(),
    this.type = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderNickname = const Value.absent(),
    this.senderProfileImageUrl = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  ChatMessagesCacheCompanion.insert({
    this.id = const Value.absent(),
    required int roomId,
    required int meetingId,
    this.type = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderNickname = const Value.absent(),
    this.senderProfileImageUrl = const Value.absent(),
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.unreadCount = const Value.absent(),
    required DateTime syncedAt,
  }) : roomId = Value(roomId),
       meetingId = Value(meetingId),
       content = Value(content),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<ChatMessagesCacheData> custom({
    Expression<int>? id,
    Expression<int>? roomId,
    Expression<int>? meetingId,
    Expression<String>? type,
    Expression<int>? senderId,
    Expression<String>? senderNickname,
    Expression<String>? senderProfileImageUrl,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? unreadCount,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (meetingId != null) 'meeting_id': meetingId,
      if (type != null) 'type': type,
      if (senderId != null) 'sender_id': senderId,
      if (senderNickname != null) 'sender_nickname': senderNickname,
      if (senderProfileImageUrl != null)
        'sender_profile_image_url': senderProfileImageUrl,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  ChatMessagesCacheCompanion copyWith({
    Value<int>? id,
    Value<int>? roomId,
    Value<int>? meetingId,
    Value<String>? type,
    Value<int?>? senderId,
    Value<String?>? senderNickname,
    Value<String?>? senderProfileImageUrl,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? unreadCount,
    Value<DateTime>? syncedAt,
  }) {
    return ChatMessagesCacheCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      meetingId: meetingId ?? this.meetingId,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      senderNickname: senderNickname ?? this.senderNickname,
      senderProfileImageUrl:
          senderProfileImageUrl ?? this.senderProfileImageUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (meetingId.present) {
      map['meeting_id'] = Variable<int>(meetingId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<int>(senderId.value);
    }
    if (senderNickname.present) {
      map['sender_nickname'] = Variable<String>(senderNickname.value);
    }
    if (senderProfileImageUrl.present) {
      map['sender_profile_image_url'] = Variable<String>(
        senderProfileImageUrl.value,
      );
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCacheCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('meetingId: $meetingId, ')
          ..write('type: $type, ')
          ..write('senderId: $senderId, ')
          ..write('senderNickname: $senderNickname, ')
          ..write('senderProfileImageUrl: $senderProfileImageUrl, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatRoomsCacheTable chatRoomsCache = $ChatRoomsCacheTable(this);
  late final $ChatMessagesCacheTable chatMessagesCache =
      $ChatMessagesCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    chatRoomsCache,
    chatMessagesCache,
  ];
}

typedef $$ChatRoomsCacheTableCreateCompanionBuilder =
    ChatRoomsCacheCompanion Function({
      Value<int> roomId,
      required int meetingId,
      required String meetingTitle,
      required String placeText,
      required DateTime scheduledAt,
      required String meetingStatus,
      required DateTime chatJoinedAt,
      required DateTime roomCreatedAt,
      required DateTime roomUpdatedAt,
      Value<int?> lastMessageId,
      Value<int?> lastMessageSenderId,
      Value<String?> lastMessageSenderNickname,
      Value<String?> lastMessageContent,
      Value<DateTime?> lastMessageCreatedAt,
      Value<int> unreadCount,
      required DateTime syncedAt,
    });
typedef $$ChatRoomsCacheTableUpdateCompanionBuilder =
    ChatRoomsCacheCompanion Function({
      Value<int> roomId,
      Value<int> meetingId,
      Value<String> meetingTitle,
      Value<String> placeText,
      Value<DateTime> scheduledAt,
      Value<String> meetingStatus,
      Value<DateTime> chatJoinedAt,
      Value<DateTime> roomCreatedAt,
      Value<DateTime> roomUpdatedAt,
      Value<int?> lastMessageId,
      Value<int?> lastMessageSenderId,
      Value<String?> lastMessageSenderNickname,
      Value<String?> lastMessageContent,
      Value<DateTime?> lastMessageCreatedAt,
      Value<int> unreadCount,
      Value<DateTime> syncedAt,
    });

class $$ChatRoomsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ChatRoomsCacheTable> {
  $$ChatRoomsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meetingTitle => $composableBuilder(
    column: $table.meetingTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeText => $composableBuilder(
    column: $table.placeText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meetingStatus => $composableBuilder(
    column: $table.meetingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get chatJoinedAt => $composableBuilder(
    column: $table.chatJoinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get roomCreatedAt => $composableBuilder(
    column: $table.roomCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get roomUpdatedAt => $composableBuilder(
    column: $table.roomUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageSenderId => $composableBuilder(
    column: $table.lastMessageSenderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageSenderNickname => $composableBuilder(
    column: $table.lastMessageSenderNickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageContent => $composableBuilder(
    column: $table.lastMessageContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageCreatedAt => $composableBuilder(
    column: $table.lastMessageCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatRoomsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatRoomsCacheTable> {
  $$ChatRoomsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meetingTitle => $composableBuilder(
    column: $table.meetingTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeText => $composableBuilder(
    column: $table.placeText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meetingStatus => $composableBuilder(
    column: $table.meetingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get chatJoinedAt => $composableBuilder(
    column: $table.chatJoinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get roomCreatedAt => $composableBuilder(
    column: $table.roomCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get roomUpdatedAt => $composableBuilder(
    column: $table.roomUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageSenderId => $composableBuilder(
    column: $table.lastMessageSenderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageSenderNickname => $composableBuilder(
    column: $table.lastMessageSenderNickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageContent => $composableBuilder(
    column: $table.lastMessageContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageCreatedAt => $composableBuilder(
    column: $table.lastMessageCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatRoomsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatRoomsCacheTable> {
  $$ChatRoomsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<int> get meetingId =>
      $composableBuilder(column: $table.meetingId, builder: (column) => column);

  GeneratedColumn<String> get meetingTitle => $composableBuilder(
    column: $table.meetingTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeText =>
      $composableBuilder(column: $table.placeText, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meetingStatus => $composableBuilder(
    column: $table.meetingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get chatJoinedAt => $composableBuilder(
    column: $table.chatJoinedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get roomCreatedAt => $composableBuilder(
    column: $table.roomCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get roomUpdatedAt => $composableBuilder(
    column: $table.roomUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageSenderId => $composableBuilder(
    column: $table.lastMessageSenderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessageSenderNickname => $composableBuilder(
    column: $table.lastMessageSenderNickname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessageContent => $composableBuilder(
    column: $table.lastMessageContent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMessageCreatedAt => $composableBuilder(
    column: $table.lastMessageCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ChatRoomsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatRoomsCacheTable,
          ChatRoomsCacheData,
          $$ChatRoomsCacheTableFilterComposer,
          $$ChatRoomsCacheTableOrderingComposer,
          $$ChatRoomsCacheTableAnnotationComposer,
          $$ChatRoomsCacheTableCreateCompanionBuilder,
          $$ChatRoomsCacheTableUpdateCompanionBuilder,
          (
            ChatRoomsCacheData,
            BaseReferences<
              _$AppDatabase,
              $ChatRoomsCacheTable,
              ChatRoomsCacheData
            >,
          ),
          ChatRoomsCacheData,
          PrefetchHooks Function()
        > {
  $$ChatRoomsCacheTableTableManager(
    _$AppDatabase db,
    $ChatRoomsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatRoomsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatRoomsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatRoomsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> roomId = const Value.absent(),
                Value<int> meetingId = const Value.absent(),
                Value<String> meetingTitle = const Value.absent(),
                Value<String> placeText = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<String> meetingStatus = const Value.absent(),
                Value<DateTime> chatJoinedAt = const Value.absent(),
                Value<DateTime> roomCreatedAt = const Value.absent(),
                Value<DateTime> roomUpdatedAt = const Value.absent(),
                Value<int?> lastMessageId = const Value.absent(),
                Value<int?> lastMessageSenderId = const Value.absent(),
                Value<String?> lastMessageSenderNickname = const Value.absent(),
                Value<String?> lastMessageContent = const Value.absent(),
                Value<DateTime?> lastMessageCreatedAt = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
              }) => ChatRoomsCacheCompanion(
                roomId: roomId,
                meetingId: meetingId,
                meetingTitle: meetingTitle,
                placeText: placeText,
                scheduledAt: scheduledAt,
                meetingStatus: meetingStatus,
                chatJoinedAt: chatJoinedAt,
                roomCreatedAt: roomCreatedAt,
                roomUpdatedAt: roomUpdatedAt,
                lastMessageId: lastMessageId,
                lastMessageSenderId: lastMessageSenderId,
                lastMessageSenderNickname: lastMessageSenderNickname,
                lastMessageContent: lastMessageContent,
                lastMessageCreatedAt: lastMessageCreatedAt,
                unreadCount: unreadCount,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> roomId = const Value.absent(),
                required int meetingId,
                required String meetingTitle,
                required String placeText,
                required DateTime scheduledAt,
                required String meetingStatus,
                required DateTime chatJoinedAt,
                required DateTime roomCreatedAt,
                required DateTime roomUpdatedAt,
                Value<int?> lastMessageId = const Value.absent(),
                Value<int?> lastMessageSenderId = const Value.absent(),
                Value<String?> lastMessageSenderNickname = const Value.absent(),
                Value<String?> lastMessageContent = const Value.absent(),
                Value<DateTime?> lastMessageCreatedAt = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                required DateTime syncedAt,
              }) => ChatRoomsCacheCompanion.insert(
                roomId: roomId,
                meetingId: meetingId,
                meetingTitle: meetingTitle,
                placeText: placeText,
                scheduledAt: scheduledAt,
                meetingStatus: meetingStatus,
                chatJoinedAt: chatJoinedAt,
                roomCreatedAt: roomCreatedAt,
                roomUpdatedAt: roomUpdatedAt,
                lastMessageId: lastMessageId,
                lastMessageSenderId: lastMessageSenderId,
                lastMessageSenderNickname: lastMessageSenderNickname,
                lastMessageContent: lastMessageContent,
                lastMessageCreatedAt: lastMessageCreatedAt,
                unreadCount: unreadCount,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatRoomsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatRoomsCacheTable,
      ChatRoomsCacheData,
      $$ChatRoomsCacheTableFilterComposer,
      $$ChatRoomsCacheTableOrderingComposer,
      $$ChatRoomsCacheTableAnnotationComposer,
      $$ChatRoomsCacheTableCreateCompanionBuilder,
      $$ChatRoomsCacheTableUpdateCompanionBuilder,
      (
        ChatRoomsCacheData,
        BaseReferences<_$AppDatabase, $ChatRoomsCacheTable, ChatRoomsCacheData>,
      ),
      ChatRoomsCacheData,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesCacheTableCreateCompanionBuilder =
    ChatMessagesCacheCompanion Function({
      Value<int> id,
      required int roomId,
      required int meetingId,
      Value<String> type,
      Value<int?> senderId,
      Value<String?> senderNickname,
      Value<String?> senderProfileImageUrl,
      required String content,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> unreadCount,
      required DateTime syncedAt,
    });
typedef $$ChatMessagesCacheTableUpdateCompanionBuilder =
    ChatMessagesCacheCompanion Function({
      Value<int> id,
      Value<int> roomId,
      Value<int> meetingId,
      Value<String> type,
      Value<int?> senderId,
      Value<String?> senderNickname,
      Value<String?> senderProfileImageUrl,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> unreadCount,
      Value<DateTime> syncedAt,
    });

class $$ChatMessagesCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesCacheTable> {
  $$ChatMessagesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderNickname => $composableBuilder(
    column: $table.senderNickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderProfileImageUrl => $composableBuilder(
    column: $table.senderProfileImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesCacheTable> {
  $$ChatMessagesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderNickname => $composableBuilder(
    column: $table.senderNickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderProfileImageUrl => $composableBuilder(
    column: $table.senderProfileImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesCacheTable> {
  $$ChatMessagesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<int> get meetingId =>
      $composableBuilder(column: $table.meetingId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderNickname => $composableBuilder(
    column: $table.senderNickname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderProfileImageUrl => $composableBuilder(
    column: $table.senderProfileImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ChatMessagesCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesCacheTable,
          ChatMessagesCacheData,
          $$ChatMessagesCacheTableFilterComposer,
          $$ChatMessagesCacheTableOrderingComposer,
          $$ChatMessagesCacheTableAnnotationComposer,
          $$ChatMessagesCacheTableCreateCompanionBuilder,
          $$ChatMessagesCacheTableUpdateCompanionBuilder,
          (
            ChatMessagesCacheData,
            BaseReferences<
              _$AppDatabase,
              $ChatMessagesCacheTable,
              ChatMessagesCacheData
            >,
          ),
          ChatMessagesCacheData,
          PrefetchHooks Function()
        > {
  $$ChatMessagesCacheTableTableManager(
    _$AppDatabase db,
    $ChatMessagesCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> roomId = const Value.absent(),
                Value<int> meetingId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> senderId = const Value.absent(),
                Value<String?> senderNickname = const Value.absent(),
                Value<String?> senderProfileImageUrl = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
              }) => ChatMessagesCacheCompanion(
                id: id,
                roomId: roomId,
                meetingId: meetingId,
                type: type,
                senderId: senderId,
                senderNickname: senderNickname,
                senderProfileImageUrl: senderProfileImageUrl,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
                unreadCount: unreadCount,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int roomId,
                required int meetingId,
                Value<String> type = const Value.absent(),
                Value<int?> senderId = const Value.absent(),
                Value<String?> senderNickname = const Value.absent(),
                Value<String?> senderProfileImageUrl = const Value.absent(),
                required String content,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> unreadCount = const Value.absent(),
                required DateTime syncedAt,
              }) => ChatMessagesCacheCompanion.insert(
                id: id,
                roomId: roomId,
                meetingId: meetingId,
                type: type,
                senderId: senderId,
                senderNickname: senderNickname,
                senderProfileImageUrl: senderProfileImageUrl,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
                unreadCount: unreadCount,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesCacheTable,
      ChatMessagesCacheData,
      $$ChatMessagesCacheTableFilterComposer,
      $$ChatMessagesCacheTableOrderingComposer,
      $$ChatMessagesCacheTableAnnotationComposer,
      $$ChatMessagesCacheTableCreateCompanionBuilder,
      $$ChatMessagesCacheTableUpdateCompanionBuilder,
      (
        ChatMessagesCacheData,
        BaseReferences<
          _$AppDatabase,
          $ChatMessagesCacheTable,
          ChatMessagesCacheData
        >,
      ),
      ChatMessagesCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatRoomsCacheTableTableManager get chatRoomsCache =>
      $$ChatRoomsCacheTableTableManager(_db, _db.chatRoomsCache);
  $$ChatMessagesCacheTableTableManager get chatMessagesCache =>
      $$ChatMessagesCacheTableTableManager(_db, _db.chatMessagesCache);
}
