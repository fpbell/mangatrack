// presentation/providers/discover_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/features/discover/data/repositories/discover_repository.dart';
import 'package:mangatrack/src/features/discover/domain/entities/genre.entity.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';

const int _maxPages = 3;
const int _maxManga = 60;

class DiscoverState {
  final List<MangaEntity> mangaList;
  final List<GenreEntity> genres;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasNextPage;
  final String query;
  final List<int> selectedGenreIds;

  const DiscoverState({
    this.mangaList = const [],
    this.genres = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasNextPage = true,
    this.query = '',
    this.selectedGenreIds = const [],
  });

  bool get reachedCap =>
      currentPage >= _maxPages || mangaList.length >= _maxManga;

  DiscoverState copyWith({
    List<MangaEntity>? mangaList,
    List<GenreEntity>? genres,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasNextPage,
    String? query,
    List<int>? selectedGenreIds,
    bool clearError = false,
  }) => DiscoverState(
    mangaList: mangaList ?? this.mangaList,
    genres: genres ?? this.genres,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: clearError ? null : error ?? this.error,
    currentPage: currentPage ?? this.currentPage,
    hasNextPage: hasNextPage ?? this.hasNextPage,
    query: query ?? this.query,
    selectedGenreIds: selectedGenreIds ?? this.selectedGenreIds,
  );
}

class DiscoverNotifier extends Notifier<DiscoverState> {
  @override
  DiscoverState build() {
    Future.microtask(() => _init());
    return const DiscoverState(isLoading: true); // ← start with loading true
  }

  // ← sequential: genres first then manga avoids race condition
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

  Future<void> fetchManga({String? query, List<int>? genreIds}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      query: query ?? state.query,
      selectedGenreIds: genreIds ?? state.selectedGenreIds,
    );

    try {
      final List<MangaEntity> manga = await ref
          .read(discoverRepositoryProvider)
          .fetchManga(
            page: 1,
            query: state.query.isEmpty ? null : state.query,
            genreIds: state.selectedGenreIds.isEmpty
                ? null
                : state.selectedGenreIds,
          );

      state = state.copyWith(
        mangaList: List<MangaEntity>.from(manga),
        isLoading: false,
        currentPage: 1,
        hasNextPage: manga.isNotEmpty,
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

  Future<void> toggleGenre(int genreId) async {
    final current = List<int>.from(state.selectedGenreIds);
    if (current.contains(genreId)) {
      current.remove(genreId);
    } else {
      current.add(genreId);
    }
    await fetchManga(genreIds: current);
  }

  Future<void> clearGenres() async {
    await fetchManga(genreIds: []);
  }

  Future<void> loadNextPage() async {
    if (state.reachedCap || !state.hasNextPage || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final List<MangaEntity> manga = await ref
          .read(discoverRepositoryProvider)
          .fetchManga(
            page: state.currentPage + 1,
            query: state.query.isEmpty ? null : state.query,
            genreIds: state.selectedGenreIds.isEmpty
                ? null
                : state.selectedGenreIds,
          );

      state = state.copyWith(
        mangaList: List<MangaEntity>.from([...state.mangaList, ...manga]),
        isLoadingMore: false,
        currentPage: state.currentPage + 1,
        hasNextPage: manga.isNotEmpty && !state.reachedCap,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void refresh() =>
      fetchManga(query: state.query, genreIds: state.selectedGenreIds);
}

final discoverProvider = NotifierProvider<DiscoverNotifier, DiscoverState>(
  DiscoverNotifier.new,
);
