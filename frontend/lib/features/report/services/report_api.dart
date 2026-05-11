import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/services/auth_api.dart';
import '../../auth/services/token_storage.dart';
import '../models/report_model.dart';

class ReportApi {
  final String baseUrl;
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  ReportApi({
    required this.baseUrl,
    required this.authApi,
    required this.tokenStorage,
  });

  Future<void> createReport({required ReportCreateModel report}) async {
    final url = Uri.parse('$baseUrl/api/report');

    final response = await _authorizedPost(
      url,
      body: jsonEncode(report.toJson()),
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(json['message'] ?? '신고 접수에 실패했습니다.');
  }

  Future<http.Response> _authorizedPost(Uri url, {String? body}) async {
    String? accessToken = await tokenStorage.getAccessToken();

    http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: body,
    );

    if (response.statusCode != 401) {
      return response;
    }

    final refreshToken = await tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('로그인이 만료되었습니다.');
    }

    final tokenResponse = await authApi.updateAccessToken(
      refreshToken: refreshToken,
    );

    final newAccessToken = tokenResponse['access_token'] as String;
    final newRefreshToken = tokenResponse['refresh_token'] as String;

    await tokenStorage.saveAccessToken(newAccessToken);
    await tokenStorage.saveRefreshToken(newRefreshToken);

    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $newAccessToken',
      },
      body: body,
    );
  }
}
