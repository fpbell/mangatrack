// features/browse/presentation/providers/browse_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/features/discover/domain/entities/genre.entity.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';
import 'browse_genre_provider.dart';
import 'browse_manga_provider.dart';

class BrowseState {
  final List<GenreEntity> genres;
  final Map<String, List<MangaEntity>> mangaByGenre;
  final List<String> activeGenres;
  final bool isLoading;
  final bool isLoadingMore; // ← add
  final String? error;

  const BrowseState({
    this.genres = const [],
    this.mangaByGenre = const {},
    this.activeGenres = const [],
    this.isLoading = false,
    this.isLoadingMore = false, // ← add
    this.error,
  });

  BrowseState copyWith({
    List<GenreEntity>? genres,
    Map<String, List<MangaEntity>>? mangaByGenre,
    List<String>? activeGenres,
    bool? isLoading,
    bool? isLoadingMore, // ← add
    String? error,
    bool clearError = false,
  }) => BrowseState(
    genres: genres ?? this.genres,
    mangaByGenre: mangaByGenre ?? this.mangaByGenre,
    activeGenres: activeGenres ?? this.activeGenres,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore, // ← add
    error: clearError ? null : error ?? this.error,
  );
}

// features/browse/presentation/providers/browse_provider.dart
final browseProvider = Provider<BrowseState>((ref) {
  final genreState = ref.watch(browseGenreProvider);
  final mangaState = ref.watch(browseMangaProvider);

  // full screen spinner only on first load
  final isLoading = genreState.isLoading || mangaState.isLoading;
  final error = genreState.error ?? mangaState.error;

  if (isLoading) {
    return BrowseState(isLoading: isLoading, error: error);
  }

  if (error != null && mangaState.mangaList.isEmpty) {
    return BrowseState(error: error);
  }

  final Map<String, List<MangaEntity>> grouped = {};
  for (final m in mangaState.mangaList) {
    for (final genre in m.genres) {
      grouped.putIfAbsent(genre, () => []).add(m);
    }
  }

  final activeGenres = genreState.genres
      .map((g) => g.name)
      .where((name) => grouped.containsKey(name))
      .toList();

  return BrowseState(
    genres: genreState.genres,
    mangaByGenre: grouped,
    activeGenres: activeGenres,
    isLoading: false,
    isLoadingMore: mangaState.isLoadingMore, // ← pass through
  );
});

// ← replaces StateProvider<int> with Notifier<int>
class ActiveGenreNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final browseActiveGenreProvider = NotifierProvider<ActiveGenreNotifier, int>(
  ActiveGenreNotifier.new,
);
