// features/favourite/presentation/providers/favourite_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';
import 'package:mangatrack/src/services/secure_storage.service.dart';

class FavouriteState {
  final List<MangaEntity> favourites;
  final Set<int> favouriteIds; // ← for O(1) lookup in discover screen
  final bool isLoading;

  const FavouriteState({
    this.favourites = const [],
    this.favouriteIds = const {},
    this.isLoading = false,
  });

  FavouriteState copyWith({
    List<MangaEntity>? favourites,
    Set<int>? favouriteIds,
    bool? isLoading,
  }) => FavouriteState(
    favourites: favourites ?? this.favourites,
    favouriteIds: favouriteIds ?? this.favouriteIds,
    isLoading: isLoading ?? this.isLoading,
  );
}

class FavouriteNotifier extends Notifier<FavouriteState> {
  @override
  FavouriteState build() {
    Future.microtask(() => _loadFromStorage());
    return const FavouriteState(isLoading: true);
  }

  Future<void> _loadFromStorage() async {
    try {
      final raw = await SecureStorageService.loadFavourites();

      if (raw.isEmpty) {
        // ← guard empty list
        state = state.copyWith(isLoading: false);
        return;
      }

      final favourites = raw.map((e) => MangaEntity.fromJson(e)).toList();

      state = state.copyWith(
        favourites: favourites,
        favouriteIds: favourites.map((e) => e.malId).toSet(),
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
      ); // ← never crash, just clear loading
    }
  }

  Future<void> toggleFavourite(MangaEntity manga) async {
    final isFav = state.favouriteIds.contains(manga.malId);

    if (isFav) {
      await _remove(manga.malId);
    } else {
      await _add(manga);
    }
  }

  Future<void> _add(MangaEntity manga) async {
    final updated = [...state.favourites, manga];
    state = state.copyWith(
      favourites: updated,
      favouriteIds: {...state.favouriteIds, manga.malId},
    );
    await _persist(updated);
  }

  Future<void> _remove(int malId) async {
    final updated = state.favourites.where((m) => m.malId != malId).toList();
    final updatedIds = {...state.favouriteIds}..remove(malId);
    state = state.copyWith(favourites: updated, favouriteIds: updatedIds);
    await _persist(updated);
  }

  Future<void> _persist(List<MangaEntity> favourites) async {
    await SecureStorageService.saveFavourites(
      favourites.map((e) => e.toJson()).toList(),
    );
  }
}

final favouriteProvider = NotifierProvider<FavouriteNotifier, FavouriteState>(
  FavouriteNotifier.new,
);
