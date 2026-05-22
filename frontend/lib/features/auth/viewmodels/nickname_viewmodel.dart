import 'package:flutter/material.dart';
import '../models/login_response_model.dart';
import '../services/auth_api.dart';
import '../services/token_storage.dart';

class NicknameViewModel extends ChangeNotifier {
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  NicknameViewModel({required this.authApi, required this.tokenStorage});

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;
  UserModel? updatedUser;
  Future<void> submitNickname(
    String nickname, {
    String? gender,
    String? ageRange,
  }) async {
    final trimmedNickname = nickname.trim();

    if (trimmedNickname.isEmpty) {
      errorMessage = '닉네임을 입력해주세요.';
      notifyListeners();
      return;
    }

    if (trimmedNickname.length < 2 || trimmedNickname.length > 12) {
      errorMessage = '닉네임은 최소 2자, 최대 12자입니다.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    isSuccess = false;
    notifyListeners();

    try {
      final accessToken = await tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage = '로그인 정보가 없습니다.';
        isLoading = false;
        notifyListeners();
        return;
      }

      updatedUser = await authApi.completeOnboarding(
        accessToken: accessToken,
        nickname: trimmedNickname,
        gender: gender,
        ageRange: ageRange,
      );

      isSuccess = true;
    } catch (e) {
      errorMessage = '닉네임 저장에 실패했습니다.';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
