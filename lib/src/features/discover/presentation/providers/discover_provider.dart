import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';
import 'package:mangatrack/src/features/discover/data/repositories/discover_repository.dart';

class DiscoverState {
  final List<MangaEntity> mangaList;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasNextPage;

  const DiscoverState({
    this.mangaList = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasNextPage = true,
  });

  DiscoverState copyWith({
    List<MangaEntity>? mangaList,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasNextPage,
  }) => DiscoverState(
    mangaList: mangaList ?? this.mangaList,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    currentPage: currentPage ?? this.currentPage,
    hasNextPage: hasNextPage ?? this.hasNextPage,
  );
}

class DiscoverNotifier extends Notifier<DiscoverState> {
  @override
  DiscoverState build() {
    fetchManga();
    return const DiscoverState();
  }

  Future<void> fetchManga({String? query}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final manga = await ref
          .read(discoverRepositoryProvider)
          .fetchManga(query: query);

      state = state.copyWith(
        mangaList: manga,
        isLoading: false,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final manga = await ref
          .read(discoverRepositoryProvider)
          .fetchManga(page: nextPage);

      state = state.copyWith(
        mangaList: [...state.mangaList, ...manga],
        isLoading: false,
        currentPage: nextPage,
        hasNextPage: manga.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refresh() => fetchManga();
}

final discoverProvider = NotifierProvider<DiscoverNotifier, DiscoverState>(
  DiscoverNotifier.new,
);
