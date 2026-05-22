import 'package:flutter/foundation.dart';
import '../models/weather_response_model.dart';
import '../services/weather_api.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherApi weatherApi;

  WeatherViewModel({required this.weatherApi});

  WeatherResponseModel? weather;
  bool isLoading = false;
  String? errorMessage;
  bool _hasLoaded = false;
  bool _isDisposed = false;

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> loadWeather() async {
    if (_isDisposed || _hasLoaded || isLoading) return;

    try {
      isLoading = true;
      errorMessage = null;
      _safeNotify();

      final result = await weatherApi.getJejuWeather();
      if (_isDisposed) return;

      weather = result;
      _hasLoaded = true;
    } catch (e) {
      errorMessage = '날씨 정보를 불러오지 못했습니다.';
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        _safeNotify();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
