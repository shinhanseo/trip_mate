import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/app_error.dart';

import '../models/mypage_model.dart';
import '../services/mypage_api.dart';

class MyPageViewModel extends ChangeNotifier {
  final MyPageApi myPageApi;

  MyPageViewModel({required this.myPageApi});

  MyPageModel? myInfo;
  bool isLoading = false;
  bool isDeleting = false;
  String? errorMessage;
  bool isSuccess = false;

  Future<void> getMe() async {
    try {
      if (isLoading) return;

      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await myPageApi.getMe();

      myInfo = result;
      isSuccess = true;
    } catch (e, stackTrace) {
      logAppError('Failed to load my page', e, stackTrace);
      errorMessage = AppErrorMessages.myPage;
      isSuccess = false;
      myInfo = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser() async {
    try {
      if (isDeleting) return;

      isDeleting = true;
      errorMessage = null;
      notifyListeners();

      await myPageApi.deleteUser();
    } catch (e, stackTrace) {
      logAppError('Failed to delete user', e, stackTrace);
      errorMessage = AppErrorMessages.accountDelete;
      rethrow;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
