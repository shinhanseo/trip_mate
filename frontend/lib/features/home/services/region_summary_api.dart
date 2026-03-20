import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/region_summary_model.dart';

class HomeRegionSummaryApi {
  final String baseUrl;

  HomeRegionSummaryApi({required this.baseUrl});

  Future<List<RegionSummaryModel>> fetchRegionSummaryList({
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/meeting/home');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final items = json['data']['item'] as List<dynamic>;

      return items
          .map((e) => RegionSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(json['message'] ?? '동행 요약 정보를 불러오지 못했습니다.');
  }
}
