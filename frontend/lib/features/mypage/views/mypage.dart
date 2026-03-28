import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';
import '../viewmodels/mypage_viewmodel.dart';
import 'package:provider/provider.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyPageViewModel>().getMe();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyPageViewModel>();

    final me = vm.myInfo;

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.errorMessage != null) {
      return Scaffold(body: Center(child: Text(vm.errorMessage!)));
    }

    if (me == null) {
      return const Scaffold(body: Center(child: Text('유저 프로필 정보가 없습니다.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        surfaceTintColor: const Color(0xffffffff),
        scrolledUnderElevation: 0,
        title: const Text('마이페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (vm.myInfo != null)
              _UserProfile(
                nickname: vm.myInfo!.nickname,
                gender: vm.myInfo!.gender,
                ageRange: vm.myInfo!.ageRange,
                bio: vm.myInfo!.bio,
                favoriteTags: vm.myInfo!.favoriteTags,
                profileImage: vm.myInfo!.profileImage,
              ),

            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF35C7B5), Color(0xFFD7E76C)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      '프로필 편집하기',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 42),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _CountItem(count: me.totalCount, label: '전체 참여한 동행'),
                ),
                Expanded(
                  child: _CountItem(count: me.hostCount, label: '내가 만든 동행'),
                ),
                Expanded(
                  child: _CountItem(count: me.ingCount, label: '현재 참가한 동행'),
                ),
              ],
            ),

            const SizedBox(height: 42),

            _MyMeetingItem(label: '전체 참여한 동행', onTap: () {}),

            const SizedBox(height: 8),
            const Divider(color: Color(0xffE5E7EB), thickness: 1, height: 1),
            const SizedBox(height: 8),

            _MyMeetingItem(label: '내가 만든 동행', onTap: () {}),

            const SizedBox(height: 8),
            const Divider(color: Color(0xffE5E7EB), thickness: 1, height: 1),
            const SizedBox(height: 8),

            _MyMeetingItem(label: '현재 참가한 동행', onTap: () {}),

            const SizedBox(height: 8),
            const Divider(color: Color(0xffE5E7EB), thickness: 1, height: 1),

            const SizedBox(height: 42),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
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
          radius: 28,
          backgroundColor: const Color(0xffF3F4F6),
          backgroundImage: NetworkImage(profileImage),
        ),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nickname,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '$ageRange / $gender',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            if (bio != null)
              Text(
                bio!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

            if (bio != null) const SizedBox(height: 4),

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

class _MyMeetingItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  _MyMeetingItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        IconButton(onPressed: onTap, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}
