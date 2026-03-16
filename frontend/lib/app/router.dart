import 'package:flutter/material.dart';
import '../features/home/views/home_page.dart';
import '../features/auth/views/login_page.dart';
import '../features/auth/views/nickname_page.dart';
import '../features/splash/views/splash_page.dart';

class AppRouter {
  static const String home = '/';
  static const String signup = '/signup';
  static const String nickname = '/nickname';
  static const String splash = '/splash';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case nickname:
        return MaterialPageRoute(
          builder: (_) => const NicknamePage(),
          settings: settings,
        );

      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
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
