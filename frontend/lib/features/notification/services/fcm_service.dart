import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'fcm_token_api.dart';

class FcmService {
  final FirebaseMessaging messaging;
  final FcmTokenApi fcmTokenApi;

  FcmService({FirebaseMessaging? messaging, required this.fcmTokenApi})
    : messaging = messaging ?? FirebaseMessaging.instance;

  Future<void> initialize() async {
    await messaging.requestPermission();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = await _waitForApnsToken();

      if (apnsToken == null || apnsToken.isEmpty) {
        return;
      }
    }

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

  Future<String?> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 10; attempt += 1) {
      final token = await messaging.getAPNSToken();

      if (token != null && token.isNotEmpty) {
        return token;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return null;
  }
}
