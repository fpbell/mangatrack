import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mangatrack/src/core/utils/debouncer.dart';
import 'package:mangatrack/src/features/discover/presentation/providers/discover_provider.dart';
import 'package:mangatrack/src/features/discover/presentation/widgets/genre_pill.widget.dart';
import 'package:mangatrack/src/shared/widgets/manga_card.widget.dart';
import 'package:mangatrack/src/features/favourite/presentation/providers/favourite_provider.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _debouncer = Debouncer(milliseconds: 500);
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debouncer.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(discoverProvider.notifier).loadNextPage();
    }
  }

  void _openSearch() {
    setState(() => _isSearching = true);
  }

  void _closeSearch() {
    FocusScope.of(context).unfocus();
    setState(() => _isSearching = false);
    _searchController.clear();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverProvider);
    final notifier = ref.read(discoverProvider.notifier);
    final favouriteIds = ref.watch(
      favouriteProvider.select((s) => s.favouriteIds),
    );

    return GestureDetector(
      onTap: _dismissKeyboard, // ← dismiss on tap anywhere
      behavior: HitTestBehavior.opaque, // ← catches taps on all areas
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: 'Search manga...',
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          _debouncer.cancel();
                          _searchController.clear();
                          notifier.clearSearch();
                        } else {
                          _closeSearch();
                        }
                      },
                    ),
                  ),
                  onChanged: (query) =>
                      _debouncer.run(() => notifier.search(query)),
                )
              : const Text(
                  'MangaTrack',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                ),
          actions: [
            if (!_isSearching)
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _openSearch,
              ),
          ],
        ),
        body: _buildBody(state, notifier, favouriteIds),
      ),
    );
  }

  Widget _buildBody(
    DiscoverState state,
    DiscoverNotifier notifier,
    Set<int> favouriteIds,
  ) {
    if (state.error != null && state.mangaList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: notifier.refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => notifier.refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (state.genres.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: GenrePills(
                  genres: state.genres,
                  selectedGenreId: state.selectedGenreId,
                  onSelect: notifier.selectGenre,
                ),
              ),
            ),

          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.mangaList.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No manga found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try a different search or genre',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final manga = state.mangaList[index];
                  return MangaCard(
                    manga: manga,
                    isFavourited: favouriteIds.contains(manga.malId),
                    useRegularImage: true,
                    onFavouriteTap: () => ref
                        .read(favouriteProvider.notifier)
                        .toggleFavourite(manga),
                    onTap: () => context.push(
                      '/viewer',
                      extra: {
                        'imageUrl': manga.largeImageUrl ?? manga.imageUrl ?? '',
                        'title': manga.title ?? 'Image Viewer',
                      },
                    ),
                  );
                }, childCount: state.mangaList.length),
              ),
            ),
            SliverToBoxAdapter(child: _buildFooter(state)),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(DiscoverState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.reachedEnd || !state.hasNextPage) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            "You've reached the end",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
