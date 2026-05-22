import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/nickname_viewmodel.dart';

class NicknamePage extends StatefulWidget {
  const NicknamePage({super.key});

  @override
  State<NicknamePage> createState() => _NicknamePageViewState();
}

class _NicknamePageViewState extends State<NicknamePage> {
  final TextEditingController _nicknameController = TextEditingController();
  String? _selectedGender;
  String? _selectedAgeRange;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NicknameViewModel>();
    final currentUser = context.watch<AuthState>().currentUser;
    final needsGender =
        currentUser?.gender == null || currentUser!.gender!.isEmpty;
    final needsAgeRange =
        currentUser?.ageRange == null || currentUser!.ageRange!.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 70),

                      const Center(
                        child: Text(
                          '닉네임 설정',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Center(
                        child: Text(
                          '다른 여행자들에게 보여질 닉네임을 설정하세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 70),

                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '최소 2자 ~ 최대 12자',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nicknameController,
                        decoration: InputDecoration(
                          hintText: '닉네임을 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.mint,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.brandMint,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.brandMint,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (needsGender) ...[
                        const Text(
                          '성별',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: [
                            _OnboardingChoiceChip(
                              label: '남성',
                              selected: _selectedGender == 'M',
                              onSelected: () =>
                                  setState(() => _selectedGender = 'M'),
                            ),
                            _OnboardingChoiceChip(
                              label: '여성',
                              selected: _selectedGender == 'F',
                              onSelected: () =>
                                  setState(() => _selectedGender = 'F'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],

                      if (needsAgeRange) ...[
                        const Text(
                          '연령대',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final ageRange in const [
                              '10대',
                              '20대',
                              '30대',
                              '40대',
                              '50대',
                              '60대 이상',
                            ])
                              _OnboardingChoiceChip(
                                label: ageRange,
                                selected: _selectedAgeRange == ageRange,
                                onSelected: () => setState(
                                  () => _selectedAgeRange = ageRange,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],

                      const Center(
                        child: Text(
                          '마이페이지에서 추후에 수정이 가능합니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
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
                              if (needsGender && _selectedGender == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('성별을 선택해주세요.')),
                                );
                                return;
                              }

                              if (needsAgeRange && _selectedAgeRange == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('연령대를 선택해주세요.')),
                                );
                                return;
                              }

                              await vm.submitNickname(
                                _nicknameController.text,
                                gender: needsGender ? _selectedGender : null,
                                ageRange: needsAgeRange
                                    ? _selectedAgeRange
                                    : null,
                              );

                              if (!context.mounted) return;

                              if (vm.isSuccess) {
                                final updatedUser = vm.updatedUser;
                                if (updatedUser != null) {
                                  context.read<AuthState>().setUser(
                                    updatedUser,
                                  );
                                }
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                );
                              } else if (vm.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(vm.errorMessage!)),
                                );
                              }
                            },
                      child: Center(
                        child: Text(
                          vm.isLoading ? '처리 중...' : '동행 시작하기',
                          style: const TextStyle(
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingChoiceChip extends StatelessWidget {
  const _OnboardingChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.brandMint,
      backgroundColor: AppColors.gray100,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.dark,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.brandMint : AppColors.gray200,
        ),
      ),
    );
  }
}
