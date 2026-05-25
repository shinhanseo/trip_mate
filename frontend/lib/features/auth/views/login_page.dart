import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/auth_api.dart';
import '../viewmodels/login_viewmodel.dart';
import '../services/token_storage.dart';
import '../viewmodels/auth_state.dart';
import '../../notification/services/fcm_token_api.dart';
import '../../notification/services/fcm_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginViewModel viewModel;
  final String baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();

    viewModel = LoginViewModel(
      authApi: AuthApi(baseUrl: baseUrl),
      tokenStorage: TokenStorage(),
    );

    viewModel.initialize();
    viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    setState(() {});

    final result = viewModel.loginResult;
    if (result == null) return;

    context.read<AuthState>().setUser(result.user);

    _registerFcmToken();

    if (result.user.profileCompleted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/nickname');
    }
  }

  Future<void> _registerFcmToken() async {
    try {
      await FcmService(
        fcmTokenApi: FcmTokenApi(
          baseUrl: baseUrl,
          authApi: AuthApi(baseUrl: baseUrl),
          tokenStorage: TokenStorage(),
        ),
      ).initialize();
    } catch (_) {
      // FCM 등록 실패가 로그인 자체를 막으면 안 됨
    }
  }

  @override
  void dispose() {
    viewModel.removeListener(_onViewModelChanged);
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              const SizedBox(height: 70),

              const Text(
                '모행',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                '지금 같은 지역 여행자들과\n바로 만나보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 70),

              Image.asset(
                'assets/images/signup_illustration.png',
                width: 280,
                fit: BoxFit.contain,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          await viewModel.startNaverLogin();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'N',
                                style: TextStyle(
                                  color: AppColors.brandGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '네이버계정으로 계속하기',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          await viewModel.startAppleLogin();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.apple, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Apple로 계속하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              const Text(
                'Apple로 시작하면 성별·연령대를 직접 선택합니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/terms');
                },
                child: const Text(
                  '이용약관(EULA) 및 커뮤니티 안전 정책 보기',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray600,
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
