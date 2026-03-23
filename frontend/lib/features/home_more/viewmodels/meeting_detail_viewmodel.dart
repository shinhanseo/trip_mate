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

  int? get currentUserId => meetingDetail?.currentUserId;
  int? get hostUserId => meetingDetail?.hostUserId;
  int? get currentMembers => meetingDetail?.currentMembers;

  Future<void> loadMeetingDetail(
    int meetingId, {
    bool forceRefresh = false,
  }) async {
    if (isLoading) return;
    if (_hasLoaded && !forceRefresh) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await meetingApi.getMeetingDetail(meetingId: meetingId);

      meetingDetail = result;
      _hasLoaded = true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      meetingDetail = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(int meetingId) async {
    await loadMeetingDetail(meetingId, forceRefresh: true);
  }

  Future<void> joinMeeting(int meetingId) async {
    try {
      isLoading = true;
      notifyListeners();

      await meetingApi.joinMeeting(meetingId: meetingId);
      final result = await meetingApi.getMeetingDetail(meetingId: meetingId);
      meetingDetail = result;
      _hasLoaded = true;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveMeeting(int meetingId) async {
    try {
      isLoading = true;
      notifyListeners();

      await meetingApi.leaveMeeting(meetingId: meetingId);
      final result = await meetingApi.getMeetingDetail(meetingId: meetingId);
      meetingDetail = result;
      _hasLoaded = true;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMeeting(int meetingId) async {
    try {
      isLoading = true;
      notifyListeners();

      await meetingApi.deleteMeeting(meetingId: meetingId);

      meetingDetail = null;
      _hasLoaded = false;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
