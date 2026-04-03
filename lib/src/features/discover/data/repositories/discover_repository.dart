import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';
import 'package:mangatrack/src/features/discover/domain/repositories/discover_repository.interface.dart';
import '../datasources/discover_remote_datasource.dart';
import '../models/manga.model.dart';

class DiscoverRepositoryImpl implements DiscoverRepository {
  final DiscoverRemoteDatasource _datasource;

  DiscoverRepositoryImpl(this._datasource);

  @override
  Future<List<MangaEntity>> fetchManga({
    int page = 1,
    String? query,
    String? status,
    String? orderBy,
    String? sort,
  }) async {
    final response = await _datasource.fetchManga(
      page: page,
      query: query,
      status: status,
      orderBy: orderBy,
      sort: sort,
    );
    return response.data.map(_toEntity).toList();
  }

  MangaEntity _toEntity(MangaModel model) => MangaEntity(
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
}

final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  return DiscoverRepositoryImpl(ref.read(discoverRemoteDatasourceProvider));
});
