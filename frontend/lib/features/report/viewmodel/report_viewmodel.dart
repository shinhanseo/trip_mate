import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/app_error.dart';

import '../models/report_model.dart';
import '../services/report_api.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportApi reportApi;

  ReportViewModel({required this.reportApi});

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> createReport({
    required ReportTargetType targetType,
    required int targetId,
    required String reason,
    String? detail,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await reportApi.createReport(
        report: ReportCreateModel(
          targetType: targetType,
          targetId: targetId,
          reason: reason,
          detail: detail,
        ),
      );

      return true;
    } catch (error, stackTrace) {
      logAppError('Failed to create report', error, stackTrace);
      _errorMessage = AppErrorMessages.report;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
