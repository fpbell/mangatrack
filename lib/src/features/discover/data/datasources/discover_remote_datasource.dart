// data/datasources/discover_remote_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/features/discover/data/models/genre.model.dart';
import 'package:mangatrack/src/features/discover/data/models/manga_response.model.dart';
import 'package:mangatrack/src/services/jikan_service.dart';

abstract class DiscoverRemoteDatasource {
  Future<MangaResponseModel> fetchManga({
    int page = 1,
    String? query,
    List<int>? genreIds, // ← List<int>
    int limit = 25,
  });

  Future<List<GenreModel>> fetchGenres();
}

class DiscoverRemoteDatasourceImpl implements DiscoverRemoteDatasource {
  @override
  Future<MangaResponseModel> fetchManga({
    int page = 1,
    String? query,
    List<int>? genreIds, // ← List<int>
    int limit = 25,
  }) async {
    final json = await JikanService.fetchManga(
      page: page,
      query: query,
      genreIds: genreIds, // ← pass list
      limit: limit,
    );
    return MangaResponseModel.fromJson(json);
  }

  @override
  Future<List<GenreModel>> fetchGenres() async {
    final json = await JikanService.fetchGenres();
    final data = json['data'] as List<dynamic>;
    return data
        .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final discoverRemoteDatasourceProvider = Provider<DiscoverRemoteDatasource>((
  ref,
) {
  return DiscoverRemoteDatasourceImpl();
});
