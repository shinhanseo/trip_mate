import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'features/auth/viewmodels/auth_state.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final naverMapClientId = dotenv.env['NAVER_MAP_CLIENT_ID'];

  if (naverMapClientId == null || naverMapClientId.isEmpty) {
    throw Exception('NAVER_MAP_CLIENT_ID가 .env에 없습니다.');
  }

  await FlutterNaverMap().init(
    clientId: naverMapClientId,
    onAuthFailed: (ex) {
      debugPrint('네이버 지도 인증 실패: $ex');
    },
  );

  runApp(
    ChangeNotifierProvider(create: (_) => AuthState(), child: const App()),
  );
}
