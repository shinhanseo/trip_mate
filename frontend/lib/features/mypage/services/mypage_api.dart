import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/services/auth_api.dart';
import '../../auth/services/token_storage.dart';
import '../models/mypage_model.dart';
import '../../home_more/models/meeting_model.dart';

class MyPageApi {
  final String baseUrl;
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  MyPageApi({
    required this.baseUrl,
    required this.authApi,
    required this.tokenStorage,
  });

  Future<MyPageModel> getMe() async {
    final url = Uri.parse('$baseUrl/api/user/mypage');

    http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return MyPageModel.fromJson(json['data']);
    }

    throw Exception(json['message'] ?? '내 정보를 불러오지 못했습니다.');
  }

  Future<MeetingListModel> getTotalMeetings({
    String? category,
    String? gender,
    String? ageGroup,
    String? regionPrimary,
    String? query,
  }) async {
    final queryParams = <String, String>{};

    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (gender != null && gender.isNotEmpty) {
      queryParams['gender'] = gender;
    }
    if (ageGroup != null && ageGroup.isNotEmpty) {
      queryParams['ageGroup'] = ageGroup;
    }
    if (regionPrimary != null && regionPrimary.isNotEmpty) {
      queryParams['regionPrimary'] = regionPrimary;
    }
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    final url = Uri.parse(
      '$baseUrl/api/user/meeting/total',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return MeetingListModel.fromJson(json['data']);
    }

    throw Exception(json['message'] ?? '동행 목록을 불러오지 못했습니다.');
  }

  Future<MeetingListModel> getHostMeetings({
    String? category,
    String? gender,
    String? ageGroup,
    String? regionPrimary,
    String? query,
  }) async {
    final queryParams = <String, String>{};

    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (gender != null && gender.isNotEmpty) {
      queryParams['gender'] = gender;
    }
    if (ageGroup != null && ageGroup.isNotEmpty) {
      queryParams['ageGroup'] = ageGroup;
    }
    if (regionPrimary != null && regionPrimary.isNotEmpty) {
      queryParams['regionPrimary'] = regionPrimary;
    }
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }
    final url = Uri.parse(
      '$baseUrl/api/user/meeting/host',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return MeetingListModel.fromJson(json['data']);
    }

    throw Exception(json['message'] ?? '동행 목록을 불러오지 못했습니다.');
  }

  Future<MeetingListModel> getIngMeetings({
    String? category,
    String? gender,
    String? ageGroup,
    String? regionPrimary,
    String? query,
  }) async {
    final queryParams = <String, String>{};

    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (gender != null && gender.isNotEmpty) {
      queryParams['gender'] = gender;
    }
    if (ageGroup != null && ageGroup.isNotEmpty) {
      queryParams['ageGroup'] = ageGroup;
    }
    if (regionPrimary != null && regionPrimary.isNotEmpty) {
      queryParams['regionPrimary'] = regionPrimary;
    }
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }
    final url = Uri.parse(
      '$baseUrl/api/user/meeting/ing',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return MeetingListModel.fromJson(json['data']);
    }

    throw Exception(json['message'] ?? '동행 목록을 불러오지 못했습니다.');
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
