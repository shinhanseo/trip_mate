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

  static const _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    borderSide: BorderSide(color: AppColors.gray200, width: 1),
  );

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
        centerTitle: false,
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
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: AppColors.gray100,
                            backgroundImage:
                                (_profileImageUrl != null &&
                                    _profileImageUrl!.isNotEmpty)
                                ? NetworkImage(_profileImageUrl!)
                                : null,
                            child:
                                (_profileImageUrl == null ||
                                    _profileImageUrl!.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    size: 44,
                                    color: AppColors.gray400,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Material(
                            color: AppColors.brandTeal,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _pickAndUploadImage,
                              child: const SizedBox(
                                width: 36,
                                height: 36,
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 19,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _nicknameController.text.trim().isEmpty
                          ? '새로운 동행자'
                          : _nicknameController.text.trim(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${myInfo.gender} · ${myInfo.ageRange}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              _EditSection(
                title: '기본 정보',
                children: [
                  _LabeledField(
                    label: '닉네임',
                    child: TextFormField(
                      controller: _nicknameController,
                      maxLength: 20,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                        hintText: '닉네임을 입력해주세요',
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _EditSection(
                title: '공개 프로필',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ReadonlyInfoTile(
                          label: '성별',
                          value: myInfo.gender,
                          icon: Icons.wc_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ReadonlyInfoTile(
                          label: '연령',
                          value: myInfo.ageRange,
                          icon: Icons.cake_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: '한줄 소개',
                    child: TextFormField(
                      controller: _bioController,
                      maxLength: 80,
                      minLines: 1,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        hintText: '나를 소개하는 짧은 문장을 적어주세요',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _EditSection(
                title: '관심 태그',
                subtitle: '프로필에 보여줄 관심사를 골라주세요.',
                children: [
                  MeetingCategoryMultiChip(
                    selectedCategories: selectedCategories,
                    onChanged: (values) {
                      setState(() {
                        selectedCategories = values;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.success50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.brandMint.withValues(alpha: 0.45),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.success700,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '성별과 연령은 네이버 로그인 정보 기준으로 표시됩니다.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success700,
                        ),
                      ),
                    ),
                  ],
                ),
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
                onTap: vm.isLoading
                    ? null
                    : () async {
                        final edit = ProfileEditModel(
                          nickname: _nicknameController.text.trim(),
                          bio: _bioController.text.trim(),
                          category: selectedCategories,
                          profileImageUrl: _profileImageUrl ?? '',
                        );

                        try {
                          await context.read<ProfileEditViewModel>().editUser(
                            edit,
                          );

                          if (!context.mounted) return;
                          Navigator.pop(context, true);
                        } catch (e) {
                          if (!context.mounted) return;

                          showDialog(
                            context: context,
                            builder: (_) => CustomMessageDialog(
                              title: '수정할 수 없어요.',
                              message: e.toString().replaceFirst(
                                'Exception: ',
                                '',
                              ),
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
                            fontSize: 18,
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

  InputDecoration _inputDecoration({
    required String hintText,
    String? counterText,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      isDense: true,
      hintText: hintText,
      counterText: counterText,
      hintStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.gray400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: _fieldBorder,
      enabledBorder: _fieldBorder,
      focusedBorder: _fieldBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.brandTeal, width: 1.5),
      ),
    );
  }
}

class _EditSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _EditSection({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ],
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ReadonlyInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadonlyInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.brandTeal),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
