import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkStatusViewModel extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  Future<void> start() async {
    final result = await _connectivity.checkConnectivity();
    _setOffline(result.every((r) => r == ConnectivityResult.none));

    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _setOffline(result.every((r) => r == ConnectivityResult.none));
    });
  }

  void _setOffline(bool value) {
    if (_isOffline == value) return;
    _isOffline = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
