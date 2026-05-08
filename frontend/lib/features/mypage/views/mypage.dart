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
import '../../../core/widgets/custom_message_dialog.dart';

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

  void _openAccountSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              _AccountActionItem(
                icon: Icons.logout,
                label: '로그아웃',
                color: AppColors.dark,
                onTap: () {
                  Navigator.pop(context);
                  _confirmLogout();
                },
              ),
              const Divider(color: AppColors.gray200, height: 1),
              _AccountActionItem(
                icon: Icons.person_remove_outlined,
                label: '회원탈퇴',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteAccount();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: '로그아웃',
        message: '로그아웃하시겠습니까?',
        onConfirm: () async {
          await context.read<AuthState>().logout();

          if (!mounted) return;

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        },
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: '회원탈퇴',
        message: '탈퇴하면 프로필 정보가 삭제되고 계정을 복구할 수 없습니다. 정말 탈퇴하시겠습니까?',
        confirmText: '탈퇴하기',
        onConfirm: () async {
          final myPageViewModel = context.read<MyPageViewModel>();
          final authState = context.read<AuthState>();

          try {
            await myPageViewModel.deleteUser();
            await authState.clearLocalSession();

            if (!mounted) return;

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          } catch (e) {
            if (!mounted) return;

            showDialog(
              context: context,
              builder: (_) => CustomMessageDialog(
                title: '탈퇴할 수 없어요.',
                message: e.toString().replaceFirst('Exception: ', ''),
              ),
            );
          }
        },
      ),
    );
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
                icon: const Icon(Icons.group_outlined),
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
                icon: const Icon(Icons.group_add_outlined),
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
                icon: const Icon(Icons.groups_outlined),
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
                icon: const Icon(Icons.map_outlined),
                label: '동행 지도 확인하기',
                onTap: () {
                  Navigator.pushNamed(context, '/totalmeetingmap');
                },
              ),

              const SizedBox(height: 8),
              const Divider(color: AppColors.gray200, thickness: 1, height: 1),
              const SizedBox(height: 8),

              _MyMeetingItem(
                icon: const Icon(Icons.settings_outlined),
                label: '계정 설정',
                onTap: _openAccountSettings,
              ),

              const SizedBox(height: 8),
              const Divider(color: AppColors.gray200, thickness: 1, height: 1),

              const SizedBox(height: 42),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class _AccountActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AccountActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _MyMeetingItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _MyMeetingItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        IconButton(onPressed: onTap, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}
