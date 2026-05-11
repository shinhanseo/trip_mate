import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/meeting_shared/utils/meeting_filter_options.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_summary.dart';

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

    final categories = meetingCategoryLabels(userProfile.favoriteTags ?? []);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          userProfile.nickname,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
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
}
