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

class MeetingMemberModel {
  final int userId;
  final String nickname;
  final String? profileImageUrl;
  final String role;
  final DateTime joinedAt;
  final String gender;
  final String ageRange;

  MeetingMemberModel({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
    required this.role,
    required this.joinedAt,
    required this.gender,
    required this.ageRange,
  });

  factory MeetingMemberModel.fromJson(Map<String, dynamic> json) {
    return MeetingMemberModel(
      userId: int.parse(json['userId'].toString()),
      nickname: json['nickname'] as String? ?? '탈퇴한 사용자',
      profileImageUrl: json['profileImageUrl'] as String?,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      gender: json['gender'] as String? ?? '',
      ageRange: json['ageRange'] as String? ?? '',
    );
  }
}

class MeetingDetailModel {
  final int id;
  final int hostUserId;
  final int currentUserId;
  final String title;
  final String placeText;
  final double placeLat;
  final double placeLng;
  final String placeAddress;
  final String regionPrimary;
  final String? regionSecondary;
  final DateTime scheduledAt;
  final int maxMembers;
  final int currentMembers;
  final String gender;
  final List<String> ageGroups;
  final String category;
  final String description;
  final String status;
  final List<MeetingMemberModel> members;

  MeetingDetailModel({
    required this.id,
    required this.hostUserId,
    required this.currentUserId,
    required this.title,
    required this.placeText,
    required this.placeLat,
    required this.placeLng,
    required this.placeAddress,
    required this.regionPrimary,
    required this.regionSecondary,
    required this.scheduledAt,
    required this.maxMembers,
    required this.currentMembers,
    required this.gender,
    required this.ageGroups,
    required this.category,
    required this.description,
    required this.status,
    required this.members,
  });

  factory MeetingDetailModel.fromJson(Map<String, dynamic> json) {
    return MeetingDetailModel(
      id: int.parse(json['id'].toString()),
      hostUserId: int.parse(json['hostUserId'].toString()),
      currentUserId: int.parse(json['currentUserId'].toString()),
      title: json['title'] as String,
      placeText: json['placeText'] as String,
      placeLat: double.parse(json['placeLat'].toString()),
      placeLng: double.parse(json['placeLng'].toString()),
      placeAddress: json['placeAddress'] as String,
      regionPrimary: json['regionPrimary'] as String,
      regionSecondary: json['regionSecondary'] as String?,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      maxMembers: int.parse(json['maxMembers'].toString()),
      currentMembers: int.parse(json['currentMembers'].toString()),
      gender: json['gender'] as String,
      ageGroups: (json['ageGroups'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      category: json['category'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      members: (json['members'] as List<dynamic>)
          .map((e) => MeetingMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
