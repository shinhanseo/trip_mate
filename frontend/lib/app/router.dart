import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/home/views/home_page.dart';
import '../features/auth/views/login_page.dart';
import '../features/auth/views/nickname_page.dart';
import '../features/auth/viewmodels/nickname_viewmodel.dart';
import '../features/auth/services/auth_api.dart';
import '../features/auth/services/token_storage.dart';
import '../features/splash/views/splash_page.dart';
import '../features/chat/views/chat_page.dart';
import '../features/mypage/views/mypage.dart';

class AppRouter {
  static const String root = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String nickname = '/nickname';
  static const String splash = '/splash';
  static const String chat = '/chat';
  static const String mypage = '/mypage';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    // query string 제거
    final uri = Uri.parse(name);
    final path = uri.path.isEmpty ? '/' : uri.path;

    switch (path) {
      case root:
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case nickname:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => NicknameViewModel(
              authApi: AuthApi(baseUrl: 'http://192.168.45.203:3000'),
              tokenStorage: TokenStorage(),
            ),
            child: const NicknamePage(),
          ),
          settings: settings,
        );

      case chat:
        return MaterialPageRoute(
          builder: (_) => const ChatPage(),
          settings: settings,
        );

      case mypage:
        return MaterialPageRoute(
          builder: (_) => const MyPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('존재하지 않는 페이지입니다'))),
          settings: settings,
        );
    }
  }
}
