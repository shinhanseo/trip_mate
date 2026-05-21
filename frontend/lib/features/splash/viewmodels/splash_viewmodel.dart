import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/app_error.dart';

import '../../auth/models/login_response_model.dart';
import '../../auth/services/auth_api.dart';
import '../../auth/services/token_storage.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  SplashViewModel({required this.authApi, required this.tokenStorage});

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;
  bool shouldGoHome = false;
  bool shouldGoLogin = false;
  bool shouldGoNickname = false;

  bool _isInitializing = false;
  bool _didInitialize = false;
  bool _isDisposed = false;

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    if (_isInitializing || _didInitialize || _isDisposed) return;
    _isInitializing = true;

    try {
      isLoading = true;
      errorMessage = null;
      shouldGoHome = false;
      shouldGoLogin = false;
      shouldGoNickname = false;
      _safeNotify();

      String? accessToken = await tokenStorage.getAccessToken();
      String? refreshToken = await tokenStorage.getRefreshToken();

      if (_isDisposed) return;

      if ((accessToken == null || accessToken.isEmpty) &&
          (refreshToken == null || refreshToken.isEmpty)) {
        shouldGoLogin = true;
        return;
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        try {
          final me = await authApi.getMe(accessToken);
          if (_isDisposed) return;

          user = me;

          if (me.profileCompleted) {
            shouldGoHome = true;
          } else {
            shouldGoNickname = true;
          }

          _didInitialize = true;
          return;
        } catch (e, stackTrace) {
          logAppError(
            'Failed to validate access token during splash',
            e,
            stackTrace,
          );
        }
      }

      if (refreshToken == null || refreshToken.isEmpty) {
        await tokenStorage.clearTokens();
        if (_isDisposed) return;

        shouldGoLogin = true;
        return;
      }
      final tokens = await authApi.updateAccessToken(
        refreshToken: refreshToken,
      );
      if (_isDisposed) return;

      final newAccessToken = tokens['access_token'] as String;
      final newRefreshToken = tokens['refresh_token'] as String;

      await tokenStorage.saveAccessToken(newAccessToken);
      await tokenStorage.saveRefreshToken(newRefreshToken);

      if (_isDisposed) return;

      final me = await authApi.getMe(newAccessToken);
      if (_isDisposed) return;

      user = me;

      if (me.profileCompleted) {
        shouldGoHome = true;
      } else {
        shouldGoNickname = true;
      }

      _didInitialize = true;
    } catch (e, stackTrace) {
      logAppError('Failed to initialize splash', e, stackTrace);
      await tokenStorage.clearTokens();

      if (_isDisposed) return;

      shouldGoLogin = true;
      errorMessage = AppErrorMessages.splash;
    } finally {
      _isInitializing = false;

      if (!_isDisposed) {
        isLoading = false;
        _safeNotify();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
