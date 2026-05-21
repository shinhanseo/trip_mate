import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/app_error.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/login_response_model.dart';
import '../services/auth_api.dart';
import '../services/token_storage.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthApi authApi;
  final TokenStorage tokenStorage;
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSubscription;
  bool _isDisposed = false;
  bool _isHandlingCallback = false;

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
        _safeNotify();
      },
    );
  }

  Future<void> startNaverLogin() async {
    try {
      errorMessage = null;
      isLoading = true;
      _safeNotify();

      final url = Uri.parse(authApi.getNaverLoginUrl());

      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('네이버 로그인 페이지를 열 수 없습니다.');
      }
    } catch (e, stackTrace) {
      logAppError('Failed to start Naver login', e, stackTrace);
      isLoading = false;
      errorMessage = AppErrorMessages.auth;
      _safeNotify();
    }
  }

  Future<void> _handleLoginCallback(Uri uri) async {
    if (_isDisposed || _isHandlingCallback) return;

    final success = uri.queryParameters['success'];
    final exchangeCode = uri.queryParameters['exchangeCode'];
    final message = uri.queryParameters['message'];

    if (success == null && exchangeCode == null && message == null) {
      return;
    }

    _isHandlingCallback = true;

    try {
      if (success != 'true') {
        isLoading = false;
        if (message != null && message.isNotEmpty) {
          logAppError('Naver login callback failed', message);
        }
        errorMessage = AppErrorMessages.auth;
        return;
      }

      if (exchangeCode == null || exchangeCode.isEmpty) {
        isLoading = false;
        logAppError('Naver login callback failed', 'Missing exchangeCode');
        errorMessage = AppErrorMessages.auth;
        return;
      }

      final result = await authApi.exchangeCode(exchangeCode);

      await tokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      loginResult = result;
      errorMessage = null;
    } catch (e, stackTrace) {
      logAppError('Failed to handle Naver login callback', e, stackTrace);
      errorMessage = AppErrorMessages.auth;
    } finally {
      isLoading = false;
      _isHandlingCallback = false;
      _safeNotify();
    }
  }

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _linkSubscription?.cancel();
    super.dispose();
  }
}
