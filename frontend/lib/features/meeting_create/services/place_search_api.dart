import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/place_search_model.dart';

class PlaceSearchApi {
  final String baseUrl;

  PlaceSearchApi({required this.baseUrl});

  Future<List<PlaceSearchModel>> searchPlaces(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return [];
    }

    final url = Uri.parse(
      '$baseUrl/api/place/search',
    ).replace(queryParameters: {'q': trimmedQuery});

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final items = json['data']['items'] as List<dynamic>;

      return items
          .map((e) => PlaceSearchModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(json['message'] ?? '장소 검색에 실패했습니다.');
  }
}
