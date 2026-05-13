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

    final http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
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

    final http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return int.parse(json['data']['count'].toString());
    }

    throw Exception(json['message'] ?? '알림 개수를 불러오지 못했습니다.');
  }

  Future<void> markAsRead(int notificationId) async {
    final url = Uri.parse('$baseUrl/api/notifications/$notificationId/read');

    final http.Response response = await _authorizedPatch(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(json['message'] ?? '알림을 읽음 처리하지 못했습니다.');
  }

  Future<http.Response> _authorizedPatch(Uri url, {Object? body}) async {
    String? accessToken = await tokenStorage.getAccessToken();

    http.Response response = await http.patch(
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

    response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $newAccessToken',
      },
      body: body,
    );

    return response;
  }

  Future<void> deleteNotification(int notificationId) async {
    final url = Uri.parse('$baseUrl/api/notifications/$notificationId');

    final http.Response response = await _authorizedDelete(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(json['message'] ?? '알림을 삭제하지 못했습니다.');
  }

  Future<void> deleteAllNotifications() async {
    final url = Uri.parse('$baseUrl/api/notifications');

    final http.Response response = await _authorizedDelete(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(json['message'] ?? '알림을 모두 삭제하지 못했습니다.');
  }

  Future<http.Response> _authorizedDelete(Uri url) async {
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    http.Response response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
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

    response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $newAccessToken',
      },
    );

    return response;
  }

  Future<http.Response> _authorizedGet(Uri url) async {
    String? accessToken = await tokenStorage.getAccessToken();

    http.Response response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
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

    response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $newAccessToken',
      },
    );

    return response;
  }
}
