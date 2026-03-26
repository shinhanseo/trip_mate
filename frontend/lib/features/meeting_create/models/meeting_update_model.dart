class MeetingUpdateModel {
  final int meetingId;
  final String title;
  final String placeText;
  final double? placeLat;
  final double? placeLng;
  final String? placeAddress;
  final DateTime scheduledAt;
  final int maxMembers;
  final String gender;
  final List<String> ageGroups;
  final String category;
  final String description;

  MeetingUpdateModel({
    required this.meetingId,
    required this.title,
    required this.placeText,
    this.placeLat,
    this.placeLng,
    this.placeAddress,
    required this.scheduledAt,
    required this.maxMembers,
    required this.gender,
    required this.ageGroups,
    required this.category,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'placeText': placeText,
      'placeLat': placeLat,
      'placeLng': placeLng,
      'placeAddress': placeAddress,
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'maxMembers': maxMembers,
      'gender': gender,
      'ageGroups': ageGroups,
      'category': category,
      'description': description,
    };
  }
}
