// data/repositories/discover_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ← add this
import 'package:mangatrack/src/features/discover/data/datasources/discover_remote_datasource.dart';
import 'package:mangatrack/src/features/discover/data/models/genre.model.dart';
import 'package:mangatrack/src/features/discover/data/models/manga.model.dart';
import 'package:mangatrack/src/features/discover/domain/entities/genre.entity.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';
import 'package:mangatrack/src/features/discover/domain/repositories/discover_repository.interface.dart';

class DiscoverRepositoryImpl implements DiscoverRepository {
  final DiscoverRemoteDatasource _datasource;
  DiscoverRepositoryImpl(this._datasource);

  @override
  Future<List<MangaEntity>> fetchManga({
    int page = 1,
    String? query,
    List<int>? genreIds,
    int limit = 25,
  }) async {
    final response = await _datasource.fetchManga(
      page: page,
      query: query,
      genreIds: genreIds,
      limit: limit,
    );
    return response.data.map(_toMangaEntity).toList();
  }

  @override
  Future<List<GenreEntity>> fetchGenres() async {
    final genres = await _datasource.fetchGenres();
    return genres.map(_toGenreEntity).toList();
  }

  MangaEntity _toMangaEntity(MangaModel model) => MangaEntity(
    malId: model.malId,
    title: model.title,
    titleEnglish: model.titleEnglish,
    imageUrl: model.imageUrl,
    synopsis: model.synopsis,
    status: model.status,
    chapters: model.chapters,
    volumes: model.volumes,
    score: model.score,
    scoredBy: model.scoredBy,
    rank: model.rank,
    genres: model.genres,
  );

  GenreEntity _toGenreEntity(GenreModel model) =>
      GenreEntity(malId: model.malId, name: model.name, count: model.count);
}

// ← add this
final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  return DiscoverRepositoryImpl(ref.read(discoverRemoteDatasourceProvider));
});
