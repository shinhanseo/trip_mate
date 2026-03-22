import 'package:flutter/foundation.dart';
import '../models/meeting_model.dart';
import '../services/meeting_api.dart';
import '../../auth/services/token_storage.dart';

class HomeMoreViewModel extends ChangeNotifier {
  final MeetingApi meetingApi;
  final TokenStorage tokenStorage;
  HomeMoreViewModel({required this.meetingApi, required this.tokenStorage});

  MeetingListModel? meetingList;
  bool isLoading = false;
  String? errorMessage;

  String? selectedCategory;
  String? selectedGender;
  String? selectedAgeGroup;
  String? searchQuery;

  bool _hasLoaded = false;

  Future<void> loadMeeting({bool forceRefresh = false}) async {
    if (isLoading) return;
    if (_hasLoaded && !forceRefresh) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final accessToken = await tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage = '로그인 정보가 없습니다.';
        meetingList = null;
        return;
      }

      final result = await meetingApi.getMeetings(
        accessToken: accessToken,
        category: selectedCategory,
        gender: selectedGender,
        ageGroup: selectedAgeGroup,
        query: searchQuery,
      );

      meetingList = result;
      _hasLoaded = true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      meetingList = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadMeeting(forceRefresh: true);
  }

  Future<void> applyFilters({
    String? category,
    String? gender,
    String? ageGroup,
    String? query,
  }) async {
    selectedCategory = category;
    selectedGender = gender;
    selectedAgeGroup = ageGroup;
    searchQuery = query;
    _hasLoaded = false;

    await loadMeeting(forceRefresh: true);
  }

  void clearFilters() {
    selectedCategory = null;
    selectedGender = null;
    selectedAgeGroup = null;
    searchQuery = null;
    _hasLoaded = false;
    notifyListeners();
  }
}
