import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';
import 'package:frontend/features/meeting_shared/utils/meeting_filter_options.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mypage_viewmodel.dart';
import '../viewmodels/my_meeting_viewmodel.dart';
import '../widgets/profile_summary.dart';
import '../../auth/viewmodels/auth_state.dart';
import '../../../core/widgets/confirm_dialog.dart';

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

    final categories = meetingCategoryLabels(me.favoriteTags ?? []);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text('마이페이지'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserProfileSummary(
                nickname: me.nickname,
                gender: me.gender,
                ageRange: me.ageRange,
                bio: me.bio,
                favoriteTags: categories,
                profileImage: me.profileImage,
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
                        colors: [AppColors.brandTeal, AppColors.brandLime],
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
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/myprofileedit',
                          arguments: me,
                        );
                      },
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
                    child: ProfileCountItem(
                      count: me.totalCount,
                      label: '전체 참여한 동행',
                    ),
                  ),
                  Expanded(
                    child: ProfileCountItem(
                      count: me.hostCount,
                      label: '내가 만든 동행',
                    ),
                  ),
                  Expanded(
                    child: ProfileCountItem(
                      count: me.ingCount,
                      label: '현재 참가한 동행',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 42),

              _MyMeetingItem(
                label: '전체 참여한 동행',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/mymeetinglist',
                    arguments: MyMeetingType.total,
                  );
                },
              ),

              const SizedBox(height: 8),
              const Divider(color: AppColors.gray200, thickness: 1, height: 1),
              const SizedBox(height: 8),

              _MyMeetingItem(
                label: '내가 만든 동행',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/mymeetinglist',
                    arguments: MyMeetingType.host,
                  );
                },
              ),

              const SizedBox(height: 8),
              const Divider(color: AppColors.gray200, thickness: 1, height: 1),
              const SizedBox(height: 8),

              _MyMeetingItem(
                label: '현재 참가한 동행',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/mymeetinglist',
                    arguments: MyMeetingType.ing,
                  );
                },
              ),

              const SizedBox(height: 8),
              const Divider(color: AppColors.gray200, thickness: 1, height: 1),
              const SizedBox(height: 8),

              _MyMeetingItem(
                label: '동행 지도 확인하기',
                onTap: () {
                  Navigator.pushNamed(context, '/totalmeetingmap');
                },
              ),

              const SizedBox(height: 8),
              const Divider(color: AppColors.gray200, thickness: 1, height: 1),

              const SizedBox(height: 42),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (_) => ConfirmDialog(
                        title: '로그아웃',
                        message: '로그아웃하시겠습니까?',
                        onConfirm: () async {
                          await context.read<AuthState>().logout();

                          if (!context.mounted) return;

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.gray200),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
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
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class _MyMeetingItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MyMeetingItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
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
