import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/core/utils/debouncer.dart';
import 'package:mangatrack/src/features/discover/presentation/providers/discover_provider.dart';
import 'package:mangatrack/src/features/discover/presentation/widgets/genre_pill.widget.dart';
import 'package:mangatrack/src/features/discover/presentation/widgets/manga_card.widget.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverProvider);
    final notifier = ref.read(discoverProvider.notifier);
    final favouriteIds = ref.watch(
      favouriteProvider.select((s) => s.favouriteIds),
    );

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: Colors.black,
          autofocus: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
            focusColor: Colors.orange,
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
            suffixIcon: state.query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      notifier.clearSearch();
                    },
                  )
                : null,
          ),
          onChanged: (query) => _debouncer.run(() => notifier.search(query)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            const SizedBox(height: 15),
            if (state.genres.isNotEmpty) ...[
              GenrePills(
                genres: state.genres,
                selectedGenreIds: state.selectedGenreIds,
                onToggle: notifier.toggleGenre,
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 15),
            Expanded(child: _buildBody(state, notifier, favouriteIds)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    DiscoverState state,
    DiscoverNotifier notifier,
    Set<int> favouriteIds,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
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

    if (state.mangaList.isEmpty) {
      return Center(
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
      );
    }

    return RefreshIndicator(
      onRefresh: () async => notifier.refresh(),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 8,
          childAspectRatio:
              0.55, // ← shorter ratio gives more height for image + title
        ),
        itemCount: state.mangaList.length + 1,
        itemBuilder: (context, index) {
          if (index == state.mangaList.length) {
            // footer spans both columns
            return GridTile(child: _buildFooter(state));
          }

          final manga = state.mangaList[index];
          return MangaCard(
            manga: manga,
            isFavourited: favouriteIds.contains(manga.malId),
            onFavouriteTap: () =>
                ref.read(favouriteProvider.notifier).toggleFavourite(manga),
            onTap: () {},
          );
        },
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

    if (state.reachedCap || !state.hasNextPage) {
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
