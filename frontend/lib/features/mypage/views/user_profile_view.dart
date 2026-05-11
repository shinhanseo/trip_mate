import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/meeting_shared/utils/meeting_filter_options.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_summary.dart';
import '../../report/models/report_model.dart';
import '../../report/viewmodel/report_viewmodel.dart';
import '../../auth/viewmodels/auth_state.dart';

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
    final authState = context.watch<AuthState>();
    final currentUserId = authState.currentUser?.id;
    final isMe = currentUserId == widget.userId;
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

    final categories = meetingCategoryLabels(userProfile.favoriteTags ?? []);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Expanded(
              child: Text(
                userProfile.nickname,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(width: 12),
            if (!isMe)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (value) async {
                  if (value == 'report') {
                    await _showUserReportBottomSheet(context);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'report',
                    child: Center(
                      child: Text(
                        '신고하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.red700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
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
                child: UserProfileSummary(
                  nickname: userProfile.nickname,
                  gender: userProfile.gender,
                  ageRange: userProfile.ageRange,
                  bio: userProfile.bio,
                  favoriteTags: categories,
                  profileImage: userProfile.profileImage,
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
                        count: userProfile.totalCount,
                        label: '전체 참여한 동행',
                      ),
                    ),
                    Container(width: 1, height: 42, color: AppColors.gray200),
                    Expanded(
                      child: ProfileCountItem(
                        count: userProfile.hostCount,
                        label: '만든 동행',
                      ),
                    ),
                    Container(width: 1, height: 42, color: AppColors.gray200),
                    Expanded(
                      child: ProfileCountItem(
                        count: userProfile.ingCount,
                        label: '현재 참가한 동행',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUserReportBottomSheet(BuildContext context) async {
    final reasons = [
      '부적절한 프로필 정보',
      '욕설 또는 비방',
      '괴롭힘 또는 위협',
      '사칭 계정 의심',
      '스팸 또는 광고',
      '사기 또는 금전 요구',
      '기타',
    ];

    String? selectedReason;
    bool isSubmitting = false;
    final detailController = TextEditingController();
    final reportViewModel = context.read<ReportViewModel>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isEtc = selectedReason == '기타';
            final canSubmit =
                selectedReason != null &&
                (!isEtc || detailController.text.trim().isNotEmpty) &&
                !isSubmitting;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.gray300,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      '유저 신고하기',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '검토가 필요한 이유를 선택해주세요.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...reasons.map((reason) {
                      final selected = selectedReason == reason;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    selectedReason = reason;
                                  });
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.red50
                                  : AppColors.gray50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? AppColors.red700
                                    : AppColors.gray200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  size: 21,
                                  color: selected
                                      ? AppColors.red700
                                      : AppColors.gray400,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: selected
                                          ? AppColors.red700
                                          : AppColors.gray600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (isEtc) ...[
                      const SizedBox(height: 4),
                      TextField(
                        controller: detailController,
                        maxLines: 4,
                        maxLength: 200,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '신고 내용을 입력해주세요.',
                          hintStyle: const TextStyle(
                            color: AppColors.gray400,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: AppColors.gray50,
                          counterStyle: const TextStyle(
                            color: AppColors.gray400,
                          ),
                          contentPadding: const EdgeInsets.all(14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.gray200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.red700,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: canSubmit
                            ? () async {
                                setState(() {
                                  isSubmitting = true;
                                });

                                final success = await reportViewModel
                                    .createReport(
                                      targetType: ReportTargetType.user,
                                      targetId: widget.userId,
                                      reason: selectedReason!,
                                      detail: detailController.text,
                                    );

                                if (!context.mounted) return;

                                setState(() {
                                  isSubmitting = false;
                                });

                                Navigator.pop(sheetContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? '신고가 접수되었습니다.'
                                          : '신고 접수에 실패했습니다.',
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red700,
                          disabledBackgroundColor: AppColors.gray200,
                          foregroundColor: AppColors.white,
                          disabledForegroundColor: AppColors.gray500,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text(
                                '신고 제출하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
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
      },
    );

    detailController.dispose();
  }
}
