import 'package:flutter/foundation.dart';
import '../models/region_summary_model.dart';
import '../services/region_summary_api.dart';
import '../../auth/services/token_storage.dart';

class RegionSummaryViewModel extends ChangeNotifier {
  final HomeRegionSummaryApi regionSummaryApi;
  final TokenStorage tokenStorage;

  RegionSummaryViewModel({
    required this.regionSummaryApi,
    required this.tokenStorage,
  });

  List<RegionSummaryModel> regionSummaries = [];
  bool isLoading = false;
  String? errorMessage;
  bool _hasLoaded = false;

  Future<void> loadRegionSummary() async {
    if (_hasLoaded || isLoading) return;

    try {
      final accessToken = await tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage = '로그인 정보가 없습니다.';
        notifyListeners();
        return;
      }

      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final List<RegionSummaryModel> result = await regionSummaryApi
          .fetchRegionSummaryList(accessToken: accessToken);

      regionSummaries = result;
      _hasLoaded = true;
    } catch (e) {
      errorMessage = '동행 요약 정보를 불러오지 못했습니다.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
