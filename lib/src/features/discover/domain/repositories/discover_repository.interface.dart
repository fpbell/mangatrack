// domain/repositories/discover_repository.interface.dart
import 'package:mangatrack/src/features/discover/domain/entities/genre.entity.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';

abstract class DiscoverRepository {
  Future<List<MangaEntity>> fetchManga({
    int page = 1,
    String? query,
    List<int>? genreIds,
    int limit = 25, // ← cap at 25
  });

  Future<List<GenreEntity>> fetchGenres();
}
