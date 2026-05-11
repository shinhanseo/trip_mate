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
import 'package:url_launcher/url_launcher.dart';

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

  static final Uri _privacyPolicyUrl = Uri.parse(
    'https://quiet-lifter-473.notion.site/35d12450961b8044889cca42bc32a35d',
  );

  Future<void> _openPrivacyPolicy() async {
    final launched = await launchUrl(
      _privacyPolicyUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      showDialog(
        context: context,
        builder: (_) => const CustomMessageDialog(
          title: '개인정보처리방침을 열 수 없어요.',
          message: '잠시 후 다시 시도해주세요.',
        ),
      );
    }
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

  Future<void> _openInquiryEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'imkara123@gmail.com',
      queryParameters: {
        'subject': '[모행] 문의합니다',
        'body': '''
          안녕하세요. 모행 문의입니다.

          문의 내용:


          ---
          사용자 정보
          닉네임:
          사용자 ID:
          ''',
      },
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched) {
      if (!mounted) return;

      _showInquiryEmailFallback('imkara123@gmail.com');
    }
  }

  void _showInquiryEmailFallback(String email) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '문의하기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '메일 앱을 열 수 없어요. 아래 이메일로 문의를 보내주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: SelectableText(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [AppColors.brandTeal, AppColors.brandLime],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
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
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [AppColors.brandTeal, AppColors.brandLime],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/myprofileedit',
                              arguments: me,
                            );
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            '프로필 편집하기',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Row(
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
              ),

              const SizedBox(height: 20),

              _MyPageSection(
                children: [
                  _MyMeetingItem(
                    icon: Icons.group_outlined,
                    label: '전체 참여한 동행',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/mymeetinglist',
                        arguments: MyMeetingType.total,
                      );
                    },
                  ),
                  _MyMeetingItem(
                    icon: Icons.group_add_outlined,
                    label: '내가 만든 동행',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/mymeetinglist',
                        arguments: MyMeetingType.host,
                      );
                    },
                  ),
                  _MyMeetingItem(
                    icon: Icons.groups_outlined,
                    label: '현재 참가한 동행',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/mymeetinglist',
                        arguments: MyMeetingType.ing,
                      );
                    },
                  ),
                  _MyMeetingItem(
                    icon: Icons.map_outlined,
                    label: '동행 지도 확인하기',
                    onTap: () {
                      Navigator.pushNamed(context, '/totalmeetingmap');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _MyPageSection(
                children: [
                  _MyMeetingItem(
                    icon: Icons.privacy_tip_outlined,
                    label: '개인정보처리방침',
                    onTap: _openPrivacyPolicy,
                  ),
                  _MyMeetingItem(
                    icon: Icons.settings_outlined,
                    label: '계정 설정',
                    onTap: _openAccountSettings,
                  ),
                  _MyMeetingItem(
                    icon: Icons.support_agent_outlined,
                    label: '문의하기',
                    onTap: _openInquiryEmail,
                  ),
                ],
              ),

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

class _MyPageSection extends StatelessWidget {
  final List<Widget> children;

  const _MyPageSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(
                color: AppColors.gray200,
                thickness: 1,
                height: 1,
                indent: 58,
              ),
          ],
        ],
      ),
    );
  }
}

class _MyMeetingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MyMeetingItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.gray600),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}
