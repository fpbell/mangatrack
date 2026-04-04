// features/browse/presentation/providers/browse_manga_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/features/discover/data/models/manga.model.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';
import 'package:mangatrack/src/services/jikan_service.dart';

// features/browse/presentation/providers/browse_manga_provider.dart
class BrowseMangaState {
  final List<MangaEntity> mangaList;
  final bool isLoading;
  final bool isLoadingMore; // ← true when pages 2-4 are loading
  final String? error;

  const BrowseMangaState({
    this.mangaList = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  BrowseMangaState copyWith({
    List<MangaEntity>? mangaList,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
  }) => BrowseMangaState(
    mangaList: mangaList ?? this.mangaList,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: clearError ? null : error ?? this.error,
  );
}

class BrowseMangaNotifier extends Notifier<BrowseMangaState> {
  @override
  BrowseMangaState build() {
    Future.microtask(() => fetchManga());
    return const BrowseMangaState(isLoading: true);
  }

  Future<void> fetchManga() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      for (int page = 1; page <= 4; page++) {
        final raw = await JikanService.fetchManga(page: page, limit: 25);
        final dataList = raw['data'] as List? ?? [];

        debugPrint('[BrowseManga] page $page: ${dataList.length} items');

        final manga = dataList
            .map((e) => MangaModel.fromJson(e as Map<String, dynamic>))
            .map(_toEntity)
            .toList();

        if (page == 1) {
          // ← first page: show immediately, switch to isLoadingMore
          state = state.copyWith(
            mangaList: manga,
            isLoading: false, // ← full screen spinner stops
            isLoadingMore: true, // ← subtle indicator continues
          );
        } else if (page == 4) {
          // ← last page: append and stop all loading
          state = state.copyWith(
            mangaList: [...state.mangaList, ...manga],
            isLoadingMore: false, // ← all done
          );
        } else {
          // ← middle pages: keep appending silently
          state = state.copyWith(mangaList: [...state.mangaList, ...manga]);
        }

        if (page < 4) {
          await Future.delayed(const Duration(milliseconds: 1000));
        }
      }

      debugPrint('[BrowseManga] total loaded: ${state.mangaList.length}');
    } catch (e, st) {
      debugPrint('[BrowseManga] error: $e');
      debugPrint('[BrowseManga] stacktrace: $st');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
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

  Future<void> retry() async => fetchManga();
}

final browseMangaProvider =
    NotifierProvider<BrowseMangaNotifier, BrowseMangaState>(
      BrowseMangaNotifier.new,
    );
