// services/jikan_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class JikanService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';

  /// GET /manga/genres
  static Future<Map<String, dynamic>> fetchGenres() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/manga/genres'),
    ); // ← fix path
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// GET /manga?q={query}&genres={id}&page={n}&limit={n}
  static Future<Map<String, dynamic>> fetchManga({
    String? query,
    List<int>? genreIds, // ← changed: List instead of single int
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
      params['genres'] = genreIds.join(','); // ← comma-separated
    }

    final uri = Uri.parse('$_baseUrl/manga').replace(queryParameters: params);
    final response = await http.get(uri);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
