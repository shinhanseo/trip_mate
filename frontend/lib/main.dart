import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'features/auth/viewmodels/auth_state.dart';
import 'features/auth/services/auth_api.dart';
import 'features/auth/services/token_storage.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");

    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('BASE_URL이 .env에 없습니다.');
    }

    final naverMapClientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
    if (naverMapClientId == null || naverMapClientId.isEmpty) {
      throw Exception('NAVER_MAP_CLIENT_ID가 .env에 없습니다.');
    }

    await FlutterNaverMap().init(
      clientId: naverMapClientId,
      onAuthFailed: (ex) {},
    );

    runApp(
      ChangeNotifierProvider(
        create: (_) => AuthState(
          authApi: AuthApi(baseUrl: baseUrl),
          tokenStorage: TokenStorage(),
        ),
        child: const App(),
      ),
    );
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'TripMate bootstrap',
        context: ErrorDescription('while starting the app'),
      ),
    );

    runApp(_BootstrapErrorApp(message: error.toString()));
  }
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 56,
                ),
                const SizedBox(height: 16),
                const Text(
                  '앱 시작에 실패했습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  message.replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
