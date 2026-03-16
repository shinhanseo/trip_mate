import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/login_response_model.dart';
import '../services/auth_api.dart';
import '../services/token_storage.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthApi authApi;
  final TokenStorage tokenStorage;
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSubscription;

  bool isLoading = false;
  String? errorMessage;
  LoginResponseModel? loginResult;

  LoginViewModel({required this.authApi, required this.tokenStorage});

  void initialize() {
    _listenDeepLink();
  }

  void _listenDeepLink() {
    _linkSubscription ??= _appLinks.uriLinkStream.listen(
      (Uri uri) async {
        await _handleLoginCallback(uri);
      },
      onError: (Object error) {
        errorMessage = '딥링크 처리 중 오류가 발생했습니다.';
        notifyListeners();
      },
    );
  }

  Future<void> startNaverLogin() async {
    try {
      errorMessage = null;
      isLoading = true;
      notifyListeners();

      final url = Uri.parse(authApi.getNaverLoginUrl());

      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('네이버 로그인 페이지를 열 수 없습니다.');
      }
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> _handleLoginCallback(Uri uri) async {
    final success = uri.queryParameters['success'];
    final exchangeCode = uri.queryParameters['exchangeCode'];
    final message = uri.queryParameters['message'];

    if (success != 'true') {
      isLoading = false;
      errorMessage = message ?? '네이버 로그인에 실패했습니다.';
      notifyListeners();
      return;
    }

    if (exchangeCode == null || exchangeCode.isEmpty) {
      isLoading = false;
      errorMessage = 'exchangeCode가 없습니다.';
      notifyListeners();
      return;
    }

    try {
      final result = await authApi.exchangeCode(exchangeCode);

      await tokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      loginResult = result;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}
