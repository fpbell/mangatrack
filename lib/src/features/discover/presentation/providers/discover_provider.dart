import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/core/constants/app_constants.dart';
import 'package:mangatrack/src/features/discover/data/repositories/discover_repository.dart';
import 'package:mangatrack/src/features/discover/domain/entities/genre.entity.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';

class DiscoverState {
  final List<MangaEntity> mangaList;
  final List<GenreEntity> genres;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasNextPage;
  final bool reachedEnd;
  final String query;
  final int? selectedGenreId;

  const DiscoverState({
    this.mangaList = const [],
    this.genres = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasNextPage = true,
    this.reachedEnd = false,
    this.query = '',
    this.selectedGenreId,
  });

  bool get reachedCap =>
      currentPage >= AppConstants.maxPages ||
      mangaList.length >= AppConstants.maxManga;

  DiscoverState copyWith({
    List<MangaEntity>? mangaList,
    List<GenreEntity>? genres,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasNextPage,
    bool? reachedEnd,
    String? query,
    int? selectedGenreId,
    bool clearGenre = false,
    bool clearError = false,
  }) => DiscoverState(
    mangaList: mangaList ?? this.mangaList,
    genres: genres ?? this.genres,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: clearError ? null : error ?? this.error,
    currentPage: currentPage ?? this.currentPage,
    hasNextPage: hasNextPage ?? this.hasNextPage,
    reachedEnd: reachedEnd ?? this.reachedEnd,
    query: query ?? this.query,
    selectedGenreId: clearGenre
        ? null
        : selectedGenreId ?? this.selectedGenreId,
  );
}

class DiscoverNotifier extends Notifier<DiscoverState> {
  @override
  DiscoverState build() {
    Future.microtask(() => _init());
    return const DiscoverState(isLoading: true);
  }

  Future<void> _init() async {
    await fetchGenres();
    await fetchManga();
  }

  Future<void> fetchGenres() async {
    try {
      final genres = await ref.read(discoverRepositoryProvider).fetchGenres();
      state = state.copyWith(genres: genres);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchManga({String? query, int? genreId}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      reachedEnd: false,
      query: query ?? state.query,
      selectedGenreId: genreId ?? state.selectedGenreId,
    );

    try {
      final List<MangaEntity> manga = await ref
          .read(discoverRepositoryProvider)
          .fetchManga(
            page: 1,
            query: state.query.isEmpty ? null : state.query,
            genreIds: state.selectedGenreId != null
                ? [state.selectedGenreId!]
                : null,
            limit: AppConstants.pageLimit,
          );

      state = state.copyWith(
        mangaList: List<MangaEntity>.from(manga),
        isLoading: false,
        currentPage: 1,
        hasNextPage: manga.isNotEmpty,
        reachedEnd: manga.isEmpty,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> search(String query) async {
    await fetchManga(query: query);
  }

  Future<void> clearSearch() async {
    if (state.query.isEmpty) return;
    state = state.copyWith(query: '');
    await fetchManga(query: '');
  }

  Future<void> selectGenre(int genreId) async {
    final isSame = state.selectedGenreId == genreId;
    state = state.copyWith(
      clearGenre: isSame,
      selectedGenreId: isSame ? null : genreId,
    );
    await fetchManga();
  }

  Future<void> loadNextPage() async {
    if (state.reachedEnd || state.isLoadingMore || !state.hasNextPage) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final remaining = AppConstants.maxManga - state.mangaList.length;

      if (remaining <= 0) {
        state = state.copyWith(
          isLoadingMore: false,
          hasNextPage: false,
          reachedEnd: true,
        );
        return;
      }

      final List<MangaEntity> manga = await ref
          .read(discoverRepositoryProvider)
          .fetchManga(
            page: nextPage,
            query: state.query.isEmpty ? null : state.query,
            genreIds: state.selectedGenreId != null
                ? [state.selectedGenreId!]
                : null,
            limit: remaining.clamp(1, AppConstants.pageLimit),
          );

      final trimmed = manga.take(remaining).toList();

      final updatedList = List<MangaEntity>.from([
        ...state.mangaList,
        ...trimmed,
      ]);

      final hitPageCap = nextPage >= AppConstants.maxPages;
      final hitMangaCap = updatedList.length >= AppConstants.maxManga;
      final noMoreFromApi = manga.isEmpty;
      final isEnd = hitPageCap || hitMangaCap || noMoreFromApi;

      state = state.copyWith(
        mangaList: updatedList,
        isLoadingMore: false,
        currentPage: nextPage,
        hasNextPage: !isEnd,
        reachedEnd: isEnd,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void refresh() =>
      fetchManga(query: state.query, genreId: state.selectedGenreId);
}

final discoverProvider = NotifierProvider<DiscoverNotifier, DiscoverState>(
  DiscoverNotifier.new,
);
