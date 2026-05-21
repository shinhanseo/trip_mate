import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/app_error.dart';

import '../models/total_meeting_map_model.dart';
import '../services/mypage_api.dart';

class TotalMeetingMapViewModel extends ChangeNotifier {
  final MyPageApi myPageApi;

  TotalMeetingMapViewModel({required this.myPageApi});

  List<TotalMeetingMapModel> totalMeetingMap = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> getTotalMeetingMap() async {
    try {
      if (isLoading) return;

      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await myPageApi.getTotalMeetingMap();

      totalMeetingMap = result;
    } catch (e, stackTrace) {
      logAppError('Failed to load total meeting map', e, stackTrace);
      errorMessage = AppErrorMessages.meetingList;
      totalMeetingMap = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
