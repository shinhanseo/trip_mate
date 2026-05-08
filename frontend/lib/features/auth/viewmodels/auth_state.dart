import 'package:flutter/foundation.dart';
import '../models/login_response_model.dart';
import '../services/auth_api.dart';
import '../services/token_storage.dart';

class AuthState extends ChangeNotifier {
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  AuthState({required this.authApi, required this.tokenStorage});

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isProfileCompleted => _currentUser?.profileCompleted ?? false;

  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  void updateNickname(String nickname) {
    final user = _currentUser;
    if (user == null) return;

    _currentUser = UserModel(
      id: user.id,
      nickname: nickname,
      gender: user.gender,
      ageRange: user.ageRange,
      profileCompleted: true,
    );

    notifyListeners();
  }

  Future<void> logout() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await authApi.logout(refreshToken: refreshToken);
      }
    } catch (_) {
      // 서버 로그아웃 실패해도 로컬 로그아웃은 진행
    } finally {
      await tokenStorage.clearTokens();
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> clearLocalSession() async {
    await tokenStorage.clearTokens();
    _currentUser = null;
    notifyListeners();
  }
}
