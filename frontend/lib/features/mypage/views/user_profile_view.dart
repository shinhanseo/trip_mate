import 'package:flutter/material.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'package:provider/provider.dart';
import '../models/mypage_model.dart';

class UserProfileView extends StatefulWidget {
  final int userId;
  const UserProfileView({super.key, required this.userId});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProfileViewModel>().getUserProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserProfileViewModel>();
    final userProfile = vm.userProfile;

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.errorMessage != null) {
      return Scaffold(body: Center(child: Text(vm.errorMessage!)));
    }

    if (userProfile == null) {
      return const Scaffold(body: Center(child: Text('유저 프로필 정보가 없습니다.')));
    }

    final categories = _categoryGroups(userProfile);

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        surfaceTintColor: const Color(0xffffffff),
        scrolledUnderElevation: 0,
        title: Text(userProfile.nickname),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UserProfile(
                nickname: userProfile.nickname,
                gender: userProfile.gender,
                ageRange: userProfile.ageRange,
                bio: userProfile.bio,
                favoriteTags: categories,
                profileImage: userProfile.profileImage,
              ),

              const SizedBox(height: 42),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _CountItem(
                      count: userProfile.totalCount,
                      label: '전체 참여한 동행',
                    ),
                  ),
                  Expanded(
                    child: _CountItem(
                      count: userProfile.hostCount,
                      label: '내가 만든 동행',
                    ),
                  ),
                  Expanded(
                    child: _CountItem(
                      count: userProfile.ingCount,
                      label: '현재 참가한 동행',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<String> _categoryGroups(MyPageModel me) {
  final tags = me.favoriteTags ?? [];
  final temp = <String>[];

  if (tags.contains('activity')) temp.add('🏄 액티비티');
  if (tags.contains('food')) temp.add('🍜 식사');
  if (tags.contains('cafe')) temp.add('☕ 카페');
  if (tags.contains('tour')) temp.add('🚗 관광');
  if (tags.contains('drink')) temp.add('🍺 술');

  return temp;
}

class _UserProfile extends StatelessWidget {
  final String nickname;
  final String gender;
  final String ageRange;
  final String? bio;
  final List<String>? favoriteTags;
  final String profileImage;

  const _UserProfile({
    required this.nickname,
    required this.gender,
    required this.ageRange,
    this.bio,
    this.favoriteTags,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: const Color(0xffF3F4F6),
          backgroundImage: profileImage.isNotEmpty
              ? NetworkImage(profileImage)
              : null,
          child: profileImage.isEmpty
              ? const Icon(Icons.person, color: Color(0xff9CA3AF))
              : null,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nickname,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '$ageRange / $gender',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 4),

              if (bio != null && bio!.trim().isNotEmpty)
                Text(
                  bio!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff999999),
                  ),
                ),

              if (bio != null && bio!.trim().isNotEmpty)
                const SizedBox(height: 4),

              if (favoriteTags != null && favoriteTags!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: favoriteTags!
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF5D0A9)),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9A3412),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

              if (favoriteTags != null && favoriteTags!.isNotEmpty)
                const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountItem extends StatelessWidget {
  final int count;
  final String label;

  const _CountItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8D8D8D),
          ),
        ),
      ],
    );
  }
}
