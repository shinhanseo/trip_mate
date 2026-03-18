import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response_model.dart';

class AuthApi {
  final String baseUrl;

  AuthApi({required this.baseUrl});

  String getNaverLoginUrl() {
    return '$baseUrl/api/auth/naver';
  }

  Future<LoginResponseModel> exchangeCode(String exchangeCode) async {
    final url = Uri.parse('$baseUrl/api/auth/session/exchange');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'exchange_code': exchangeCode}),
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return LoginResponseModel.fromJson(json['data']);
    }

    throw Exception(json['message'] ?? '로그인에 실패했습니다.');
  }

  Future<UserModel> getMe(String accessToken) async {
    final url = Uri.parse('$baseUrl/api/user/me');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return UserModel.fromJson(json['data']);
    }

    throw Exception(json['message'] ?? '사용자 정보를 불러오지 못했습니다.');
  }

  Future<Map<String, dynamic>> updateAccessToken({
    required String refreshToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/refresh');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'access_token': json['data']['access_token'],
        'refresh_token': json['data']['refresh_token'],
      };
    }

    throw Exception(json['message'] ?? '토큰 업데이트를 실패했습니다.');
  }

  Future<void> updateNickname({
    required String accessToken,
    required String nickname,
  }) async {
    final url = Uri.parse('$baseUrl/api/user/nickname');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'nickname': nickname}),
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(json['message'] ?? '닉네임 설정에 실패했습니다.');
  }
}
