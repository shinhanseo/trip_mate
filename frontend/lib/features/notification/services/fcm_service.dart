import 'package:firebase_messaging/firebase_messaging.dart';

import 'fcm_token_api.dart';

class FcmService {
  final FirebaseMessaging messaging;
  final FcmTokenApi fcmTokenApi;

  FcmService({FirebaseMessaging? messaging, required this.fcmTokenApi})
    : messaging = messaging ?? FirebaseMessaging.instance;

  Future<void> initialize() async {
    await messaging.requestPermission();

    final token = await messaging.getToken();

    if (token != null && token.isNotEmpty) {
      await fcmTokenApi.registerToken(token);
    }

    messaging.onTokenRefresh.listen((newToken) async {
      if (newToken.isEmpty) return;

      try {
        await fcmTokenApi.registerToken(newToken);
      } catch (_) {}
    });
  }
}
