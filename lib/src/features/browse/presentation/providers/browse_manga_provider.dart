import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/core/constants/app_constants.dart';
import 'package:mangatrack/src/features/discover/data/models/manga.model.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';
import 'package:mangatrack/src/services/jikan_service.dart';

class BrowseMangaState {
  final List<MangaEntity> mangaList;
  final bool isLoading;
  final bool isLoadingMore;
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
      for (int page = 1; page <= AppConstants.browsePages; page++) {
        final raw = await JikanService.fetchManga(
          page: page,
          limit: AppConstants.browseLimit,
        );

        final dataList = raw['data'] as List? ?? [];
        debugPrint('[BrowseManga] page $page: ${dataList.length} items');

        final manga = dataList
            .map((e) => MangaModel.fromJson(e as Map<String, dynamic>))
            .map(_toEntity)
            .toList();

        if (page == 1) {
          state = state.copyWith(
            mangaList: manga,
            isLoading: false,
            isLoadingMore: true,
          );
        } else if (page == AppConstants.browsePages) {
          state = state.copyWith(
            mangaList: [...state.mangaList, ...manga],
            isLoadingMore: false,
          );
        } else {
          state = state.copyWith(mangaList: [...state.mangaList, ...manga]);
        }

        if (page < AppConstants.browsePages) {
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
    smallImageUrl: model.smallImageUrl,
    largeImageUrl: model.largeImageUrl,
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
