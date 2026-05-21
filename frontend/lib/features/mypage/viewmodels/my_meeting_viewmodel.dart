import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/app_error.dart';

import '../../home_more/models/meeting_model.dart';
import '../services/mypage_api.dart';

enum MyMeetingType { total, host, ing }

class MyMeetingViewModel extends ChangeNotifier {
  final MyPageApi myPageApi;
  final MyMeetingType type;

  MyMeetingViewModel({required this.myPageApi, required this.type});

  MeetingListModel? meetingList;

  bool isLoading = false;
  String? errorMessage;

  String? selectedCategory;
  String? selectedGender;
  String? selectedAgeGroup;
  String? selectedRegionPrimary;
  String? searchQuery;

  bool isSuccess = false;

  Future<void> loadMeetings({bool forceRefresh = false}) async {
    if (isLoading) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      late final MeetingListModel result;

      switch (type) {
        case MyMeetingType.total:
          result = await myPageApi.getTotalMeetings(
            category: selectedCategory,
            gender: selectedGender,
            ageGroup: selectedAgeGroup,
            regionPrimary: selectedRegionPrimary,
            query: searchQuery,
          );
          break;
        case MyMeetingType.host:
          result = await myPageApi.getHostMeetings(
            category: selectedCategory,
            gender: selectedGender,
            ageGroup: selectedAgeGroup,
            regionPrimary: selectedRegionPrimary,
            query: searchQuery,
          );
          break;
        case MyMeetingType.ing:
          result = await myPageApi.getIngMeetings(
            category: selectedCategory,
            gender: selectedGender,
            ageGroup: selectedAgeGroup,
            regionPrimary: selectedRegionPrimary,
            query: searchQuery,
          );
          break;
      }

      meetingList = result;
      isSuccess = true;
    } catch (e, stackTrace) {
      logAppError('Failed to load my meetings', e, stackTrace);
      errorMessage = AppErrorMessages.meetingList;
      isSuccess = false;
      meetingList = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadMeetings(forceRefresh: true);
  }

  Future<void> applyFilters({
    String? category,
    String? gender,
    String? ageGroup,
    String? regionPrimary,
    String? query,
  }) async {
    selectedCategory = category;
    selectedGender = gender;
    selectedAgeGroup = ageGroup;
    selectedRegionPrimary = regionPrimary;
    searchQuery = query;
    isSuccess = false;

    await loadMeetings(forceRefresh: true);
  }

  void clearFilters() {
    selectedCategory = null;
    selectedGender = null;
    selectedAgeGroup = null;
    selectedRegionPrimary = null;
    searchQuery = null;
    isSuccess = false;
    notifyListeners();
  }
}
