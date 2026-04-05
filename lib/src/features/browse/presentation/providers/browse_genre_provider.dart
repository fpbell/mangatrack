import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/features/discover/data/repositories/discover_repository.dart';
import 'package:mangatrack/src/features/discover/domain/entities/genre.entity.dart';

class BrowseGenreState {
  final List<GenreEntity> genres;
  final bool isLoading;
  final String? error;

  const BrowseGenreState({
    this.genres = const [],
    this.isLoading = false,
    this.error,
  });

  BrowseGenreState copyWith({
    List<GenreEntity>? genres,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => BrowseGenreState(
    genres: genres ?? this.genres,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : error ?? this.error,
  );
}

class BrowseGenreNotifier extends Notifier<BrowseGenreState> {
  @override
  BrowseGenreState build() {
    Future.microtask(() => fetchGenres());
    return const BrowseGenreState(isLoading: true);
  }

  Future<void> fetchGenres() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final genres = await ref.read(discoverRepositoryProvider).fetchGenres();
      state = state.copyWith(genres: genres, isLoading: false);
      debugPrint('[BrowseGenre] loaded: ${genres.length}');
    } catch (e) {
      debugPrint('[BrowseGenre] error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final browseGenreProvider =
    NotifierProvider<BrowseGenreNotifier, BrowseGenreState>(
      BrowseGenreNotifier.new,
    );
