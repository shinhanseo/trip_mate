import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../features/home/views/home_page.dart';
import '../features/home/viewmodels/weather_viewmodel.dart';
import '../features/home/viewmodels/region_summary_viewmodel.dart';
import '../features/home/services/weather_api.dart';
import '../features/home/services/region_summary_api.dart';

import '../features/auth/views/login_page.dart';
import '../features/auth/views/nickname_page.dart';
import '../features/auth/viewmodels/nickname_viewmodel.dart';
import '../features/auth/services/auth_api.dart';
import '../features/auth/services/token_storage.dart';

import '../features/home_more/views/home_more_page.dart';
import '../features/home_more/views/meeting_detail_page.dart';
import '../features/home_more/viewmodels/home_more_viewmodel.dart';
import '../features/home_more/viewmodels/meeting_detail_viewmodel.dart';
import '../features/home_more/services/meeting_api.dart';

import '../features/splash/views/splash_page.dart';
import '../features/chat/views/chat_page.dart';
import '../features/mypage/views/mypage.dart';

import '../features/meeting_create/views/meeting_create_page.dart';
import '../features/meeting_create/views/meeting_place_search_page.dart';
import '../features/meeting_create/viewmodels/place_search_viewmodel.dart';
import '../features/meeting_create/viewmodels/meeting_create_viewmodel.dart';
import '../features/meeting_create/services/place_search_api.dart';
import '../features/meeting_create/views/meeting_update_page.dart';
import '../features/meeting_create/viewmodels/meeting_update_viewmodel.dart';

class AppRouter {
  static const String root = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String nickname = '/nickname';
  static const String splash = '/splash';
  static const String chat = '/chat';
  static const String mypage = '/mypage';
  static const String homemore = '/homemore';
  static const String meetingcreate = '/meetingcreate';
  static const String meetingdetail = '/meetingdetail';
  static const String meetingplacesearch = '/meetingplacesearch';
  static const String meetingupdate = '/meetingupdate';
  static final baseUrl = dotenv.env['BASE_URL']!;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';

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
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) =>
                    WeatherViewModel(weatherApi: WeatherApi(baseUrl: baseUrl)),
              ),

              ChangeNotifierProvider(
                create: (_) => RegionSummaryViewModel(
                  regionSummaryApi: HomeRegionSummaryApi(baseUrl: baseUrl),
                ),
              ),
            ],
            child: const HomePage(),
          ),
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
              authApi: AuthApi(baseUrl: baseUrl),
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

      case homemore:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => HomeMoreViewModel(
              meetingApi: MeetingApi(
                baseUrl: baseUrl,
                authApi: AuthApi(baseUrl: baseUrl),
                tokenStorage: TokenStorage(),
              ),
            ),
            child: const HomeMorePage(),
          ),
          settings: settings,
        );

      case meetingcreate:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => MeetingCreateViewModel(
              meetingApi: MeetingApi(
                baseUrl: baseUrl,
                authApi: AuthApi(baseUrl: baseUrl),
                tokenStorage: TokenStorage(),
              ),
              authApi: AuthApi(baseUrl: baseUrl),
              tokenStorage: TokenStorage(),
            ),
            child: const MeetingCreatePage(),
          ),
        );

      case meetingdetail:
        final meetingId = settings.arguments as int;

        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => MeetingDetailViewModel(
              meetingApi: MeetingApi(
                baseUrl: baseUrl,
                authApi: AuthApi(baseUrl: baseUrl),
                tokenStorage: TokenStorage(),
              ),
            ),
            child: MeetingDetailPage(meetingId: meetingId),
          ),
          settings: settings,
        );

      case meetingplacesearch:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => PlaceSearchViewModel(
              placeSearchApi: PlaceSearchApi(baseUrl: baseUrl),
            ),
            child: const MeetingPlaceSearchPage(),
          ),
          settings: settings,
        );

      case meetingupdate:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => MeetingUpdateViewModel(
              meetingApi: MeetingApi(
                baseUrl: baseUrl,
                authApi: AuthApi(baseUrl: baseUrl),
                tokenStorage: TokenStorage(),
              ),
              authApi: AuthApi(baseUrl: baseUrl),
              tokenStorage: TokenStorage(),
            ),
            child: const MeetingUpdatePage(),
          ),
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
