import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

import '../services/terms_storage.dart';

class TermsPage extends StatefulWidget {
  final String nextRoute;

  const TermsPage({super.key, this.nextRoute = '/login'});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  final TermsStorage _termsStorage = TermsStorage();
  bool _acceptedTerms = false;
  bool _acceptedCommunity = false;
  bool _isSaving = false;

  bool get _canContinue => _acceptedTerms && _acceptedCommunity && !_isSaving;

  Future<void> _continue() async {
    if (!_canContinue) return;

    setState(() {
      _isSaving = true;
    });

    await _termsStorage.acceptTerms();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, widget.nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '모행',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '안전한 동행을 위해\nEULA에 동의해 주세요.',
                style: TextStyle(
                  fontSize: 26,
                  height: 1.28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '로그인 또는 회원가입 전에 이용약관(EULA)과 커뮤니티 안전 정책에 동의해야 모행을 이용할 수 있습니다.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _TermsSection(
                        title: '이용약관(EULA)',
                        body:
                            '모행은 여행자 간 동행 모집과 소통을 돕는 서비스입니다. 사용자는 정확한 정보를 제공하고, 타인의 권리와 안전을 침해하지 않아야 합니다. 불법 행위, 사기, 개인정보 무단 공유, 타인을 위협하거나 괴롭히는 행위는 금지됩니다. 위반 사용자는 콘텐츠 삭제, 계정 이용 제한 또는 탈퇴 조치될 수 있습니다.',
                      ),
                      const SizedBox(height: 12),
                      _TermsSection(
                        title: '커뮤니티 가이드라인',
                        body:
                            '모행은 objectionable content 또는 abusive users에 대해 무관용 원칙을 적용합니다. 욕설, 혐오, 성적 콘텐츠, 폭력적 표현, 괴롭힘, 스팸, 불쾌하거나 위험한 콘텐츠는 허용되지 않습니다. 사용자는 게시글과 프로필에서 부적절한 콘텐츠를 신고할 수 있으며, 악성 사용자를 차단할 수 있습니다.',
                      ),
                      const SizedBox(height: 12),
                      _TermsSection(
                        title: '신고 및 차단 정책',
                        body:
                            '신고 또는 차단된 콘텐츠는 신고한 사용자의 화면에서 즉시 숨김 처리됩니다. 운영자는 접수된 신고를 24시간 이내 검토하고, 위반 콘텐츠 삭제와 위반 사용자 이용 제한 또는 탈퇴 조치를 진행합니다.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _AgreementCheckbox(
                value: _acceptedTerms,
                text: '이용약관(EULA)에 동의합니다.',
                onChanged: (value) {
                  setState(() {
                    _acceptedTerms = value ?? false;
                  });
                },
              ),
              _AgreementCheckbox(
                value: _acceptedCommunity,
                text: '커뮤니티 가이드라인 및 신고/차단 정책에 동의합니다.',
                onChanged: (value) {
                  setState(() {
                    _acceptedCommunity = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _canContinue ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandTeal,
                    disabledBackgroundColor: AppColors.gray200,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: AppColors.gray500,
                    elevation: _canContinue ? 3 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          '동의하고 계속하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String body;

  const _TermsSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.48,
              fontWeight: FontWeight.w500,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementCheckbox extends StatelessWidget {
  final bool value;
  final String text;
  final ValueChanged<bool?> onChanged;

  const _AgreementCheckbox({
    required this.value,
    required this.text,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.brandTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
