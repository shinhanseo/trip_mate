import 'package:flutter/foundation.dart';
import '../models/meeting_model.dart';
import '../services/meeting_api.dart';

class MeetingDetailViewModel extends ChangeNotifier {
  final MeetingApi meetingApi;

  MeetingDetailViewModel({required this.meetingApi});

  MeetingDetailModel? meetingDetail;
  bool isLoading = false;
  String? errorMessage;
  bool _hasLoaded = false;

  Future<void> loadMeetingDetail(int meetingId) async {
    if (isLoading || _hasLoaded) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await meetingApi.getMeetingDetail(meetingId: meetingId);

      meetingDetail = result;
      _hasLoaded = true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception : ', '');
      meetingDetail = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(int meetingId) async {
    await loadMeetingDetail(meetingId);
  }
}
