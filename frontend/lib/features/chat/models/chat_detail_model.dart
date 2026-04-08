class ChatDetailModel {
  final int roomId;
  final MeetingModel meeting;
  final List<MessageModel> messages;

  ChatDetailModel({
    required this.roomId,
    required this.meeting,
    required this.messages,
  });

  factory ChatDetailModel.fromJson(Map<String, dynamic> json) {
    return ChatDetailModel(
      roomId: int.parse(json['roomId'].toString()),
      meeting: MeetingModel.fromJson(json['meeting'] as Map<String, dynamic>),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MeetingModel {
  final int meetingId;
  final int hostUserId;
  final String title;
  final String placeText;
  final DateTime scheduledAt;
  final int maxMembers;
  final int currentMembers;
  final String status;

  MeetingModel({
    required this.meetingId,
    required this.hostUserId,
    required this.title,
    required this.placeText,
    required this.scheduledAt,
    required this.maxMembers,
    required this.currentMembers,
    required this.status,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      meetingId: int.parse(json['id'].toString()),
      hostUserId: int.parse(json['hostUserId'].toString()),
      title: json['title'] as String,
      placeText: json['placeText'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      maxMembers: int.parse(json['maxMembers'].toString()),
      currentMembers: int.parse(json['currentMembers'].toString()),
      status: json['status'] as String,
    );
  }
}

class MessageModel {
  final int id;
  final int roomId;
  final int senderId;
  final String? senderNickname;
  final String? senderProfileImageUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderNickname,
    required this.senderProfileImageUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: int.parse(json['id'].toString()),
      roomId: int.parse(json['roomId'].toString()),
      senderId: int.parse(json['senderId'].toString()),
      senderNickname: json['senderNickname'] as String?,
      senderProfileImageUrl: json['senderProfileImageUrl'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
