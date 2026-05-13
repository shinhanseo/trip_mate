import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/services/auth_api.dart';
import '../../auth/services/token_storage.dart';
import '../models/notification_model.dart';

class NotificationApi {
  final String baseUrl;
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  NotificationApi({
    required this.baseUrl,
    required this.authApi,
    required this.tokenStorage,
  });

  Future<List<NotificationModel>> getNotifications({int limit = 50}) async {
    final url = Uri.parse('$baseUrl/api/notifications?limit=$limit');

    final response = await _authorizedRequest(method: 'GET', url: url);

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (_isSuccess(response)) {
      final items = json['data']['items'] as List<dynamic>;

      return items
          .map(
            (item) => NotificationModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    throw Exception(json['message'] ?? '알림을 불러오지 못했습니다.');
  }

  Future<int> getUnreadCount() async {
    final url = Uri.parse('$baseUrl/api/notifications/unread-count');

    final response = await _authorizedRequest(method: 'GET', url: url);

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (_isSuccess(response)) {
      return int.parse(json['data']['count'].toString());
    }

    throw Exception(json['message'] ?? '알림 개수를 불러오지 못했습니다.');
  }

  Future<void> markAsRead(int notificationId) async {
    final url = Uri.parse('$baseUrl/api/notifications/$notificationId/read');

    final response = await _authorizedRequest(method: 'PATCH', url: url);

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (_isSuccess(response)) return;

    throw Exception(json['message'] ?? '알림을 읽음 처리하지 못했습니다.');
  }

  Future<void> markAllAsRead() async {
    final url = Uri.parse('$baseUrl/api/notifications/read-all');

    final response = await _authorizedRequest(method: 'PATCH', url: url);

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (_isSuccess(response)) return;

    throw Exception(json['message'] ?? '알림을 모두 읽음 처리하지 못했습니다.');
  }

  Future<void> deleteNotification(int notificationId) async {
    final url = Uri.parse('$baseUrl/api/notifications/$notificationId');

    final response = await _authorizedRequest(method: 'DELETE', url: url);

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (_isSuccess(response)) return;

    throw Exception(json['message'] ?? '알림을 삭제하지 못했습니다.');
  }

  Future<void> deleteAllNotifications() async {
    final url = Uri.parse('$baseUrl/api/notifications');

    final response = await _authorizedRequest(method: 'DELETE', url: url);

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (_isSuccess(response)) return;

    throw Exception(json['message'] ?? '알림을 모두 삭제하지 못했습니다.');
  }

  bool _isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<http.Response> _authorizedRequest({
    required String method,
    required Uri url,
    Object? body,
  }) async {
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    var response = await _sendRequest(
      method: method,
      url: url,
      accessToken: accessToken,
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

    response = await _sendRequest(
      method: method,
      url: url,
      accessToken: newAccessToken,
      body: body,
    );

    return response;
  }

  Future<http.Response> _sendRequest({
    required String method,
    required Uri url,
    required String accessToken,
    Object? body,
  }) {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    switch (method) {
      case 'GET':
        return http.get(url, headers: headers);
      case 'PATCH':
        return http.patch(url, headers: headers, body: body);
      case 'DELETE':
        return http.delete(url, headers: headers);
      default:
        throw UnsupportedError('Unsupported method: $method');
    }
  }
}
