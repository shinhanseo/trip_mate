import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/app_error.dart';

import '../models/meeting_model.dart';
import '../services/meeting_api.dart';

class HomeMoreViewModel extends ChangeNotifier {
  final MeetingApi meetingApi;

  HomeMoreViewModel({required this.meetingApi});

  MeetingListModel? meetingList;
  bool isLoading = false;
  String? errorMessage;

  String? selectedCategory;
  String? selectedGender;
  String? selectedAgeGroup;
  String? selectedRegionPrimary;
  String? searchQuery;

  bool _hasLoaded = false;

  Future<void> loadMeeting({bool forceRefresh = false}) async {
    if (isLoading) return;
    if (_hasLoaded && !forceRefresh) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await meetingApi.getMeetings(
        category: selectedCategory,
        gender: selectedGender,
        ageGroup: selectedAgeGroup,
        regionPrimary: selectedRegionPrimary,
        query: searchQuery,
      );

      meetingList = result;
      _hasLoaded = true;
    } catch (e, stackTrace) {
      logAppError('Failed to load meetings', e, stackTrace);
      errorMessage = AppErrorMessages.meetingList;
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
    String? regionPrimary,
    String? query,
  }) async {
    selectedCategory = category;
    selectedGender = gender;
    selectedAgeGroup = ageGroup;
    selectedRegionPrimary = regionPrimary;
    searchQuery = query;
    _hasLoaded = false;

    await loadMeeting(forceRefresh: true);
  }

  void clearFilters() {
    selectedCategory = null;
    selectedGender = null;
    selectedAgeGroup = null;
    selectedRegionPrimary = null;
    searchQuery = null;
    _hasLoaded = false;
    notifyListeners();
  }
}
