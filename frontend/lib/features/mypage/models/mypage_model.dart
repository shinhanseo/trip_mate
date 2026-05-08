class MyPageModel {
  final int userId;
  final String nickname;
  final String gender;
  final String ageRange;
  final String? bio;
  final List<String>? favoriteTags;
  final String profileImage;
  final int totalCount;
  final int hostCount;
  final int ingCount;

  MyPageModel({
    required this.userId,
    required this.nickname,
    required this.gender,
    required this.ageRange,
    this.bio,
    this.favoriteTags,
    required this.profileImage,
    required this.totalCount,
    required this.hostCount,
    required this.ingCount,
  });

  factory MyPageModel.fromJson(Map<String, dynamic> json) {
    return MyPageModel(
      userId: int.parse(json['id'].toString()),
      nickname: json['nickname'] as String? ?? '탈퇴한 사용자',
      gender: json['gender'] as String? ?? '',
      ageRange: json['ageRange'] as String? ?? '',
      bio: json['bio'] as String?,
      favoriteTags: (json['favoriteTags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      profileImage: (json['profileImage'] ?? '') as String,
      hostCount: int.parse(json['meetingCounts']['host'].toString()),
      totalCount: int.parse(json['meetingCounts']['total'].toString()),
      ingCount: int.parse(json['meetingCounts']['ing'].toString()),
    );
  }
}
