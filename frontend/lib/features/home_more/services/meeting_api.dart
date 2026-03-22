import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/meeting_model.dart';

class MeetingApi {
  final String baseUrl;

  MeetingApi({required this.baseUrl});

  Future<MeetingListModel> getMeetings({
    required String accessToken,
    String? category,
    String? gender,
    String? ageGroup,
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

    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    final url = Uri.parse(
      '$baseUrl/api/meeting',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return MeetingListModel.fromJson(json['data']);
    }

    throw Exception(json['message'] ?? '동행 목록을 불러오지 못했습니다.');
  }
}
