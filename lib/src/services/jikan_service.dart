import 'dart:convert';
import 'package:http/http.dart' as http;

class JikanService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';

  static Future<Map<String, dynamic>> fetchGenres() async {
    final response = await http.get(Uri.parse('$_baseUrl/genres/manga'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> fetchManga({
    String? query,
    List<int>? genreIds,
    int page = 1,
    int limit = 25,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sfw': 'true',
      'genres_exclude': '12,49,28,9,22',
    };

    if (query != null && query.isNotEmpty) params['q'] = query;
    if (genreIds != null && genreIds.isNotEmpty) {
      params['genres'] = genreIds.join(',');
    }

    final uri = Uri.parse('$_baseUrl/manga').replace(queryParameters: params);
    final response = await http.get(uri);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
