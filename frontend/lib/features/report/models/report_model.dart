enum ReportTargetType {
  user('user'),
  meeting('meeting'),
  chatRoom('chat_room'),
  chatMessage('chat_message');

  const ReportTargetType(this.value);

  final String value;
}

class ReportCreateModel {
  final ReportTargetType targetType;
  final int targetId;
  final String reason;
  final String? detail;

  ReportCreateModel({
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.detail,
  });

  Map<String, dynamic> toJson() {
    final trimmedDetail = detail?.trim();

    return {
      'targetType': targetType.value,
      'targetId': targetId,
      'reason': reason.trim(),
      'detail': trimmedDetail == null || trimmedDetail.isEmpty
          ? null
          : trimmedDetail,
    };
  }
}
