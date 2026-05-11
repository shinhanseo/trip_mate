import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../features/auth/viewmodels/auth_state.dart';

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

import '../features/chat/views/chat_list_page.dart';
import '../features/chat/viewmodels/chat_list_viewmodel.dart';
import '../features/chat/services/chat_api.dart';
import '../features/chat/services/chat_socket_service.dart';
import '../features/chat/views/chat_detail_page.dart';
import '../features/chat/viewmodels/chat_detail_viewmodel.dart';

import '../features/mypage/views/mypage.dart';
import '../features/mypage/viewmodels/mypage_viewmodel.dart';
import '../features/mypage/services/mypage_api.dart';
import '../features/mypage/views/my_meeting_list_view.dart';
import '../features/mypage/viewmodels/my_meeting_viewmodel.dart';
import '../features/mypage/views/my_profile_edit_view.dart';
import '../features/mypage/viewmodels/profile_edit_viewmodel.dart';
import '../features/mypage/views/user_profile_view.dart';
import '../features/mypage/viewmodels/user_profile_viewmodel.dart';
import '../features/mypage/views/total_meeting_map_view.dart';
import '../features/mypage/viewmodels/total_meeting_map_viewmodel.dart';

import '../features/meeting_create/views/meeting_create_page.dart';
import '../features/meeting_create/views/meeting_place_search_page.dart';
import '../features/meeting_create/viewmodels/place_search_viewmodel.dart';
import '../features/meeting_create/viewmodels/meeting_create_viewmodel.dart';
import '../features/meeting_create/services/place_search_api.dart';
import '../features/meeting_create/views/meeting_update_page.dart';
import '../features/meeting_create/viewmodels/meeting_update_viewmodel.dart';

import '../features/report/viewmodel/report_viewmodel.dart';
import '../features/report/services/report_api.dart';

class AppRouter {
  static const String root = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String nickname = '/nickname';
  static const String splash = '/splash';
  static const String chatlist = '/chatlist';
  static const String mypage = '/mypage';
  static const String homemore = '/homemore';
  static const String meetingcreate = '/meetingcreate';
  static const String meetingdetail = '/meetingdetail';
  static const String meetingplacesearch = '/meetingplacesearch';
  static const String meetingupdate = '/meetingupdate';
  static const String mymeetinglist = '/mymeetinglist';
  static const String myprofileedit = '/myprofileedit';
  static const String userprofile = '/userprofile';
  static const String totalmeetingmap = '/totalmeetingmap';
  static const String chatdetail = '/chatdetail';

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

      case chatlist:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ChatListViewModel(
              chatApi: ChatApi(
                baseUrl: baseUrl,
                authApi: AuthApi(baseUrl: baseUrl),
                tokenStorage: TokenStorage(),
              ),
            ),
            child: const ChatListPage(),
          ),
          settings: settings,
        );

      case chatdetail:
        final meetingId = settings.arguments as int;

        return MaterialPageRoute(
          builder: (context) {
            final currentUserId = context.read<AuthState>().currentUser?.id;

            if (currentUserId == null) {
              return const LoginPage();
            }

            return ChangeNotifierProvider(
              create: (_) => ChatDetailViewModel(
                chatApi: ChatApi(
                  baseUrl: baseUrl,
                  authApi: AuthApi(baseUrl: baseUrl),
                  tokenStorage: TokenStorage(),
                ),
                chatSocketService: ChatSocketService(socketBaseUrl: baseUrl),
                currentUserId: currentUserId,
              ),
              child: ChatDetailPage(meetingId: meetingId),
            );
          },
          settings: settings,
        );

      case mypage:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => MyPageViewModel(
              myPageApi: MyPageApi(
                baseUrl: baseUrl,
                authApi: AuthApi(baseUrl: baseUrl),
                tokenStorage: TokenStorage(),
              ),
            ),
            child: const MyPage(),
          ),
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
          settings: settings,
        );

      case meetingdetail:
        final meetingId = settings.arguments as int;

        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => MeetingDetailViewModel(
                  meetingApi: MeetingApi(
                    baseUrl: baseUrl,
                    authApi: AuthApi(baseUrl: baseUrl),
                    tokenStorage: TokenStorage(),
                  ),
                ),
              ),
              ChangeNotifierProvider(
                create: (_) => ReportViewModel(
                  reportApi: ReportApi(
                    baseUrl: baseUrl,
                    authApi: AuthApi(baseUrl: baseUrl),
                    tokenStorage: TokenStorage(),
                  ),
                ),
              ),
            ],
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
          settings: settings,
        );

      case mymeetinglist:
        final type = settings.arguments as MyMeetingType;

        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => MyMeetingViewModel(
              myPageApi: MyPageApi(
                baseUrl: baseUrl,
                authApi: AuthApi(baseUrl: baseUrl),
                tokenStorage: TokenStorage(),
              ),
              type: type,
            ),
            child: MyMeetingListPage(type: type),
          ),
          settings: settings,
        );

      case myprofileedit:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ProfileEditViewModel(
              myPageApi: MyPageApi(
                baseUrl: baseUrl,
                authApi: AuthApi(baseUrl: baseUrl),
                tokenStorage: TokenStorage(),
              ),
            ),
            child: const MyProfileEditPage(),
          ),
          settings: settings,
        );

      case userprofile:
        final userId = settings.arguments as int;

        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => UserProfileViewModel(
                  myPageApi: MyPageApi(
                    baseUrl: baseUrl,
                    authApi: AuthApi(baseUrl: baseUrl),
                    tokenStorage: TokenStorage(),
                  ),
                ),
              ),
              ChangeNotifierProvider(
                create: (_) => ReportViewModel(
                  reportApi: ReportApi(
                    baseUrl: baseUrl,
                    authApi: AuthApi(baseUrl: baseUrl),
                    tokenStorage: TokenStorage(),
                  ),
                ),
              ),
            ],
            child: UserProfileView(userId: userId),
          ),
          settings: settings,
        );

      case totalmeetingmap:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => TotalMeetingMapViewModel(
              myPageApi: MyPageApi(
                baseUrl: baseUrl,
                authApi: AuthApi(baseUrl: baseUrl),
                tokenStorage: TokenStorage(),
              ),
            ),
            child: const TotalMeetingMapView(),
          ),
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
