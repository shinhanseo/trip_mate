import 'package:flutter/foundation.dart';

import '../models/place_search_model.dart';
import '../services/place_search_api.dart';

class PlaceSearchViewModel extends ChangeNotifier {
  final PlaceSearchApi placeSearchApi;

  PlaceSearchViewModel({required this.placeSearchApi});

  List<PlaceSearchModel> places = [];
  bool isLoading = false;
  String? errorMessage;
  String query = '';

  Future<void> searchPlaces(String value) async {
    final trimmed = value.trim();

    query = trimmed;

    if (trimmed.isEmpty) {
      places = [];
      errorMessage = null;
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await placeSearchApi.searchPlaces(trimmed);
      places = result;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      places = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    query = '';
    places = [];
    errorMessage = null;
    notifyListeners();
  }
}
