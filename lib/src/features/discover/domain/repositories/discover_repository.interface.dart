import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';

abstract class DiscoverRepository {
  Future<List<MangaEntity>> fetchManga({
    int page = 1,
    String? query,
    String? status,
    String? orderBy,
    String? sort,
  });
}
