class ChatListModel {
  final int roomId;
  final int meetingId;
  final String meetingTitle;
  final String placeText;
  final DateTime scheduledAt;
  final String meetingStatus;
  final DateTime chatJoinedAt;
  final DateTime roomCreatedAt;
  final DateTime roomUpdatedAt;

  ChatListModel({
    required this.roomId,
    required this.meetingId,
    required this.meetingTitle,
    required this.placeText,
    required this.scheduledAt,
    required this.meetingStatus,
    required this.chatJoinedAt,
    required this.roomCreatedAt,
    required this.roomUpdatedAt,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) {
    return ChatListModel(
      roomId: int.parse(json['roomId'].toString()),
      meetingId: int.parse(json['meetingId'].toString()),
      meetingTitle: json['meetingTitle'] as String,
      placeText: json['placeText'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      meetingStatus: json['meetingStatus'] as String,
      chatJoinedAt: DateTime.parse(json['chatJoinedAt'] as String),
      roomCreatedAt: DateTime.parse(json['roomCreatedAt'] as String),
      roomUpdatedAt: DateTime.parse(json['roomUpdatedAt'] as String),
    );
  }
}
