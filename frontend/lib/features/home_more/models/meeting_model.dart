class MeetingModel {
  final int id;
  final String title;
  final String placeText;
  final DateTime scheduledAt;
  final int maxMembers;
  final int currentMembers;
  final String gender;
  final List<String> ageGroups;
  final String category;
  final String regionPrimary;

  MeetingModel({
    required this.id,
    required this.title,
    required this.placeText,
    required this.scheduledAt,
    required this.maxMembers,
    required this.currentMembers,
    required this.gender,
    required this.ageGroups,
    required this.category,
    required this.regionPrimary,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: int.parse(json['id'].toString()),
      title: json['title'] as String,
      placeText: json['placeText'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      maxMembers: int.parse(json['maxMembers'].toString()),
      currentMembers: int.parse(json['currentMembers'].toString()),
      gender: json['gender'] as String,
      ageGroups: (json['ageGroups'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      category: json['category'] as String,
      regionPrimary: json['regionPrimary'] as String,
    );
  }
}

class MeetingListModel {
  final int userId;
  final List<MeetingModel> items;

  MeetingListModel({required this.userId, required this.items});

  factory MeetingListModel.fromJson(Map<String, dynamic> json) {
    return MeetingListModel(
      userId: int.parse(json['userId'].toString()),
      items: (json['items'] as List<dynamic>)
          .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
