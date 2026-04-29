import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/auth_api.dart';
import '../../auth/services/token_storage.dart';
import '../models/chat_list_model.dart';
import '../models/chat_detail_model.dart';

class ChatApi {
  final String baseUrl;
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  ChatApi({
    required this.baseUrl,
    required this.authApi,
    required this.tokenStorage,
  });

  Future<List<ChatListModel>> getChatRoomList() async {
    final url = Uri.parse('$baseUrl/api/chat/rooms');

    http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final items = json['data']['items'] as List<dynamic>;

      return items
          .map((e) => ChatListModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(json['message'] ?? '채팅방 목록 조회에 실패했습니다.');
  }

  Future<ChatDetailModel> getChatDetail(int meetingId) async {
    final url = Uri.parse('$baseUrl/api/chat/meetings/$meetingId/messages');

    http.Response response = await _authorizedGet(url);

    final Map<String, dynamic> json = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final item = json['data']['item'] as Map<String, dynamic>;
      return ChatDetailModel.fromJson(item);
    }

    throw Exception(json['message'] ?? '채팅방 조회에 실패했습니다.');
  }

  Future<String> getValidAccessToken({bool forceRefresh = false}) async {
    final accessToken = await tokenStorage.getAccessToken();

    if (!forceRefresh && accessToken != null && accessToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode != 401) {
        return accessToken;
      }
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

    return newAccessToken;
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
