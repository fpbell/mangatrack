import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JikanService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';

  static Future<Map<String, dynamic>> fetchGenres() async {
    final response = await http.get(Uri.parse('$_baseUrl/genres/manga'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // services/jikan_service.dart
  static Future<Map<String, dynamic>> fetchManga({
    String? query,
    List<int>? genreIds,
    int page = 1,
    int limit = 25, // ← max allowed by Jikan
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sfw': 'true',
    };

    if (query != null && query.isNotEmpty) params['q'] = query;
    if (genreIds != null && genreIds.isNotEmpty) {
      params['genres'] = genreIds.join(',');
    }

    final baseUri = Uri.parse(
      '$_baseUrl/manga',
    ).replace(queryParameters: params);
    final finalUri = Uri.parse(
      '${baseUri.toString()}&genres_exclude=12,49,28,9,22',
    );

    debugPrint('[JikanService] fetchManga URL: $finalUri');

    final response = await http.get(finalUri);

    debugPrint('[JikanService] status: ${response.statusCode}');

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
