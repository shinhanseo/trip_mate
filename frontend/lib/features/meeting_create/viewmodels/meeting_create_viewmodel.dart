import 'package:flutter/foundation.dart';

import '../../auth/services/auth_api.dart';
import '../../auth/services/token_storage.dart';
import '../models/meeting_create_model.dart';
import '../../home_more/services/meeting_api.dart';

class MeetingCreateViewModel extends ChangeNotifier {
  final MeetingApi meetingApi;
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  MeetingCreateViewModel({
    required this.meetingApi,
    required this.authApi,
    required this.tokenStorage,
  });

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;

  String? gender;
  String? ageRange;

  Future<void> loadMe() async {
    try {
      final accessToken = await tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      final me = await authApi.getMe(accessToken);

      gender = _normalizeGender(me.gender);
      ageRange = _normalizeAgeRange(me.ageRange);

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> createMeeting(MeetingCreateModel meeting) async {
    try {
      isLoading = true;
      errorMessage = null;
      isSuccess = false;
      notifyListeners();

      await meetingApi.createMeeting(meeting: meeting);

      isSuccess = true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isSuccess = false;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String? _normalizeGender(String? value) {
    switch (value) {
      case 'M':
        return 'male';
      case 'F':
        return 'female';
      default:
        return value;
    }
  }

  String? _normalizeAgeRange(String? value) {
    switch (value) {
      case '20-29':
        return '20s';
      case '30-39':
        return '30s';
      case '40-49':
        return '40s';
      case '50-59':
        return '50s';
      default:
        return value;
    }
  }
}
