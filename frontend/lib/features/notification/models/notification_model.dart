class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String body;
  final String? targetType;
  final int? targetId;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.targetType,
    required this.targetId,
    required this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  NotificationModel copyWith({
    int? id,
    String? type,
    String? title,
    String? body,
    String? targetType,
    int? targetId,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: int.parse(json['id'].toString()),
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      targetType: json['targetType'] as String?,
      targetId: json['targetId'] == null
          ? null
          : int.parse(json['targetId'].toString()),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
