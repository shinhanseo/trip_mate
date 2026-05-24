import 'package:flutter/material.dart';
import 'package:frontend/core/utils/app_error.dart';

import '../services/mypage_api.dart';
import '../models/mypage_model.dart';

class UserProfileViewModel extends ChangeNotifier {
  final MyPageApi myPageApi;

  UserProfileViewModel({required this.myPageApi});

  MyPageModel? userProfile;
  bool isLoading = false;
  bool isBlocking = false;
  String? errorMessage;
  bool isSuccess = false;

  Future<void> getUserProfile(int userId) async {
    try {
      if (isLoading) return;

      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await myPageApi.getUserProfile(userId: userId);
      userProfile = result;
      isSuccess = true;
    } catch (e, stackTrace) {
      logAppError('Failed to load user profile', e, stackTrace);
      errorMessage = AppErrorMessages.profile;
      isSuccess = false;
      userProfile = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> blockUser(int userId) async {
    if (isBlocking) return false;

    try {
      isBlocking = true;
      errorMessage = null;
      notifyListeners();

      await myPageApi.blockUser(userId: userId);
      return true;
    } catch (e, stackTrace) {
      logAppError('Failed to block user', e, stackTrace);
      errorMessage = '사용자 차단에 실패했습니다.';
      return false;
    } finally {
      isBlocking = false;
      notifyListeners();
    }
  }
}
