import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/services/auth_api.dart';
import '../../auth/services/token_storage.dart';
import '../../auth/viewmodels/auth_state.dart';
import '../viewmodels/splash_viewmodel.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = SplashViewModel(
      authApi: AuthApi(baseUrl: 'http://172.20.10.3:3000'),
      tokenStorage: TokenStorage(),
    );

    viewModel.addListener(_onChanged);
    viewModel.initialize();
  }

  void _onChanged() {
    if (!mounted) return;

    setState(() {});

    if (viewModel.user != null) {
      context.read<AuthState>().setUser(viewModel.user!);
    }

    if (viewModel.shouldGoHome) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    if (viewModel.shouldGoNickname) {
      Navigator.pushReplacementNamed(context, '/nickname');
      return;
    }

    if (viewModel.shouldGoLogin) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    viewModel.removeListener(_onChanged);
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: viewModel.isLoading
            ? const CircularProgressIndicator()
            : const Text(
                '모행',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
