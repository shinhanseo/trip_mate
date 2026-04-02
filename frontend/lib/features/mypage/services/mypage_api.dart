import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/services/auth_api.dart';
import '../../auth/services/token_storage.dart';
import '../models/mypage_model.dart';
import '../models/profile_edit_model.dart';
import '../models/total_meeting_map_model.dart';
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

  Future<ProfileEditModel> editUser({required ProfileEditModel edit}) async {
    final url = Uri.parse('$baseUrl/api/user/profile');

    final profile = ProfileEditModel(
      nickname: edit.nickname,
      bio: edit.bio,
      category: edit.category,
      profileImageUrl: edit.profileImageUrl,
    );

    final response = await _authorizedPatch(
      url,
      body: jsonEncode(profile.toJson()),
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ProfileEditModel(
        nickname: json['data']['item']['nickname'] as String,
        bio: json['data']['item']['bio'] as String,
        category: (json['data']['item']['category'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
        profileImageUrl: json['data']['item']['profileImageUrl'] as String,
      );
    }

    throw Exception(json['message'] ?? '프로필 수정에 실패했습니다.');
  }

  Future<String> uploadProfileImage(String filePath) async {
    final url = Uri.parse('$baseUrl/api/upload/profile-image');

    String? accessToken = await tokenStorage.getAccessToken();

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 401) {
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

      request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $newAccessToken';
      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json['data']['imageUrl'] as String;
    }

    throw Exception(json['message'] ?? '프로필 이미지 업로드에 실패했습니다.');
  }

  Future<MyPageModel> getUserProfile({required int userId}) async {
    final url = Uri.parse('$baseUrl/api/user/$userId/profile');

    http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return MyPageModel.fromJson(json['data']);
    }

    throw Exception(json['message'] ?? '유저 프로필을 불러오지 못했습니다.');
  }

  Future<TotalMeetingMapModel> getTotalMeetingMap() async {
    final url = Uri.parse('$baseUrl/api/user/map');

    http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return TotalMeetingMapModel.fromJson(json['data']);
    }

    throw Exception(json['message'] ?? '동행 지도를 불러오지 못했습니다.');
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
