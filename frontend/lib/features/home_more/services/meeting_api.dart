import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/services/auth_api.dart';
import '../../auth/services/token_storage.dart';
import '../models/meeting_model.dart';
import '../../meeting_create/models/meeting_create_model.dart';
import '../../meeting_create/models/meeting_update_model.dart';

class MeetingApi {
  final String baseUrl;
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  MeetingApi({
    required this.baseUrl,
    required this.authApi,
    required this.tokenStorage,
  });

  Future<MeetingListModel> getMeetings({
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
      '$baseUrl/api/meeting',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return MeetingListModel.fromJson(json['data']);
    }

    throw Exception(json['message'] ?? '동행 목록을 불러오지 못했습니다.');
  }

  Future<MeetingDetailModel> getMeetingDetail({int? meetingId}) async {
    final url = Uri.parse('$baseUrl/api/meeting/$meetingId');

    http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return MeetingDetailModel.fromJson(json['data']['item']);
    }

    throw Exception(json['message'] ?? '동행 세부 사항을 불러오지 못했습니다.');
  }

  Future<void> joinMeeting({required int meetingId}) async {
    final url = Uri.parse('$baseUrl/api/meeting/$meetingId/join');

    http.Response response = await _authorizedPost(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(json['message'] ?? '동행 참여에 실패했습니다.');
  }

  Future<void> leaveMeeting({required int meetingId}) async {
    final url = Uri.parse('$baseUrl/api/meeting/$meetingId/leave');

    http.Response response = await _authorizedPost(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(json['message'] ?? '동행 나가기에 실패했습니다.');
  }

  Future<void> deleteMeeting({required int meetingId}) async {
    final url = Uri.parse('$baseUrl/api/meeting/$meetingId');

    http.Response response = await _authorizedDelete(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(json['message'] ?? '동행 삭제에 실패했습니다.');
  }

  Future<void> createMeeting({required MeetingCreateModel meeting}) async {
    final url = Uri.parse('$baseUrl/api/meeting');

    final response = await _authorizedPost(
      url,
      body: jsonEncode(meeting.toJson()),
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(json['message'] ?? '동행 생성에 실패했습니다.');
  }

  Future<void> updateMeeting({required MeetingUpdateModel meeting}) async {
    final url = Uri.parse('$baseUrl/api/meeting/${meeting.meetingId}');

    final response = await _authorizedPatch(
      url,
      body: jsonEncode(meeting.toJson()),
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(json['message'] ?? '동행 수정에 실패했습니다.');
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

  Future<http.Response> _authorizedPost(Uri url, {Object? body}) async {
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

    response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $newAccessToken',
      },
      body: body,
    );

    return response;
  }

  Future<http.Response> _authorizedDelete(Uri url) async {
    String? accessToken = await tokenStorage.getAccessToken();

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
}
