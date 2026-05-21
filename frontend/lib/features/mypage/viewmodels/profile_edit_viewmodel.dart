import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/app_error.dart';

import '../services/mypage_api.dart';
import '../models/profile_edit_model.dart';

class ProfileEditViewModel extends ChangeNotifier {
  final MyPageApi myPageApi;

  ProfileEditViewModel({required this.myPageApi});

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;

  Future<void> editUser(ProfileEditModel edit) async {
    try {
      isLoading = true;
      errorMessage = null;
      isSuccess = false;
      notifyListeners();

      await myPageApi.editUser(edit: edit);
      isSuccess = true;
    } catch (e, stackTrace) {
      logAppError('Failed to edit profile', e, stackTrace);
      errorMessage = AppErrorMessages.profileEdit;
      isSuccess = false;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> uploadProfileImage(String filePath) async {
    return await myPageApi.uploadProfileImage(filePath);
  }
}
