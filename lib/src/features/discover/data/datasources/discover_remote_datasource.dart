import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mangatrack/src/core/constants/app_constants.dart';
import '../models/manga_response.model.dart';

abstract class DiscoverRemoteDatasource {
  Future<MangaResponseModel> fetchManga({
    int page = 1,
    String? query,
    String? status,
    String? orderBy,
    String? sort,
  });
}

class DiscoverRemoteDatasourceImpl implements DiscoverRemoteDatasource {
  final http.Client _client;

  DiscoverRemoteDatasourceImpl(this._client);

  @override
  Future<MangaResponseModel> fetchManga({
    int page = 1,
    String? query,
    String? status,
    String? orderBy,
    String? sort,
  }) async {
    final queryParams = {
      'page': page.toString(),
      if (query != null) 'q': query,
      if (status != null) 'status': status,
      if (orderBy != null) 'order_by': orderBy,
      if (sort != null) 'sort': sort,
    };

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/manga',
    ).replace(queryParameters: queryParams);

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return MangaResponseModel.fromJson(json);
    } else {
      throw Exception('Failed to fetch manga: ${response.statusCode}');
    }
  }
}

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final discoverRemoteDatasourceProvider = Provider<DiscoverRemoteDatasource>((
  ref,
) {
  return DiscoverRemoteDatasourceImpl(ref.read(httpClientProvider));
});
