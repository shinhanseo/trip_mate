import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/meeting_shared/widgets/meeting_filter_chips.dart';
import '../models/mypage_model.dart';
import '../models/profile_edit_model.dart';
import '../viewmodels/profile_edit_viewmodel.dart';
import '../../../core/widgets/custom_message_dialog.dart';
import 'package:image_picker/image_picker.dart';

class MyProfileEditPage extends StatefulWidget {
  const MyProfileEditPage({super.key});

  @override
  State<MyProfileEditPage> createState() => _MyProfileEditPageState();
}

class _MyProfileEditPageState extends State<MyProfileEditPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isInitialized = false;
  List<String> selectedCategories = [];

  String? _profileImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null) {
      final myInfo = args as MyPageModel;
      _profileImageUrl = myInfo.profileImage;
      _nicknameController.text = myInfo.nickname;
      _bioController.text = myInfo.bio ?? '';
      selectedCategories = List<String>.from(myInfo.favoriteTags ?? []);
    }

    _isInitialized = true;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final viewModel = context.read<ProfileEditViewModel>();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    try {
      final imageUrl = await viewModel.uploadProfileImage(pickedFile.path);

      if (!mounted) return;

      setState(() {
        _profileImageUrl = imageUrl;
      });
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => CustomMessageDialog(
          title: '업로드할 수 없어요.',
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileEditViewModel>();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          scrolledUnderElevation: 0,
          title: const Text(
            '프로필 편집',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: const Center(child: Text('프로필 정보가 없습니다.')),
      );
    }

    final myInfo = args as MyPageModel;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          '프로필 편집',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.gray100,
                  backgroundImage:
                      (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                      ? const Icon(Icons.person, color: AppColors.gray400)
                      : null,
                ),
              ),

              const SizedBox(height: 18),

              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 26,
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
                      onPressed: () async {
                        await _pickAndUploadImage();
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 62),

              Row(
                children: [
                  const SizedBox(
                    width: 75,
                    child: Text(
                      '닉네임',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: _nicknameController,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: AppColors.mint,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: AppColors.brandMint,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: AppColors.brandMint,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(color: AppColors.gray200, thickness: 1, height: 1),
              const SizedBox(height: 18),

              Row(
                children: [
                  const SizedBox(
                    width: 85,
                    child: Text(
                      '성별',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    myInfo.gender,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(color: AppColors.gray200, thickness: 1, height: 1),
              const SizedBox(height: 18),

              Row(
                children: [
                  const SizedBox(
                    width: 85,
                    child: Text(
                      '연령',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    myInfo.ageRange,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(color: AppColors.gray200, thickness: 1, height: 1),
              const SizedBox(height: 18),

              Row(
                children: [
                  const SizedBox(
                    width: 70,
                    child: Text(
                      '한줄 소개',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: AppColors.mint,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: AppColors.brandMint,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: AppColors.brandMint,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(color: AppColors.gray200, thickness: 1, height: 1),
              const SizedBox(height: 18),

              Row(
                children: [
                  const SizedBox(
                    width: 35,
                    child: Text(
                      '태그',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MeetingCategoryMultiChip(
                      selectedCategories: selectedCategories,
                      onChanged: (values) {
                        setState(() {
                          selectedCategories = values;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          height: 58,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.brandTeal, AppColors.brandLime],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  final edit = ProfileEditModel(
                    nickname: _nicknameController.text.trim(),
                    bio: _bioController.text.trim(),
                    category: selectedCategories,
                    profileImageUrl: _profileImageUrl ?? '',
                  );

                  try {
                    await context.read<ProfileEditViewModel>().editUser(edit);

                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  } catch (e) {
                    if (!context.mounted) return;

                    showDialog(
                      context: context,
                      builder: (_) => CustomMessageDialog(
                        title: '수정할 수 없어요.',
                        message: e.toString().replaceFirst('Exception: ', ''),
                      ),
                    );
                  }
                },
                child: Center(
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '변경사항 저장하기',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
