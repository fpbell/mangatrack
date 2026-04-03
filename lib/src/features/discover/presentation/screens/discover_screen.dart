// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../services/jikan_service.dart';

// class DiscoverScreen extends StatefulWidget {
//   const DiscoverScreen({super.key});

//   @override
//   State<DiscoverScreen> createState() => _DiscoverScreenState();
// }

// class _DiscoverScreenState extends State<DiscoverScreen> {
//   // -------------------------------------------------------------------------
//   // Hardcoded sample genres
//   // -------------------------------------------------------------------------

//   // TODO: replace with live genres from API once they're loaded

//   static const List<Map<String, dynamic>> _kSampleGenres = [
//     {'mal_id': 1, 'name': 'Action'},
//     {'mal_id': 2, 'name': 'Adventure'},
//     {'mal_id': 4, 'name': 'Comedy'},
//     {'mal_id': 8, 'name': 'Drama'},
//     {'mal_id': 10, 'name': 'Fantasy'},
//     {'mal_id': 14, 'name': 'Horror'},
//     {'mal_id': 22, 'name': 'Romance'},
//     {'mal_id': 36, 'name': 'Slice of Life'},
//   ];

//   List<dynamic> genres = []; // populated from /manga/genres on init
//   List<dynamic> mangaList = []; // populated from /manga on init
//   bool isLoading = false;
//   String searchQuery = '';
//   int? selectedGenreId;
//   int currentPage = 1;
//   bool hasReachedEnd = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     setState(() => isLoading = true);

//     // 1. Fetch genres
//     final genreData = await JikanService.fetchGenres();
//     setState(() => genres = (genreData['data'] as List<dynamic>?) ?? []);
//     debugPrint('[Discover] Genres loaded: ${genres.length}');

//     // 2. Fetch first page of manga
//     final mangaData = await JikanService.fetchManga(page: 1, limit: 20);
//     setState(() {
//       mangaList = (mangaData['data'] as List<dynamic>?) ?? [];
//       isLoading = false;
//     });
//     debugPrint('[Discover] Manga loaded: ${mangaList.length}');
//   }

//   void _onSearchChanged(String query) {
//     searchQuery = query;
//     // TODO: trigger a new fetch with the updated search query
//   }

//   void _onGenreChanged(int? genreId) {
//     // TODO: make changes accordingly
//     _fetchFilteredWithGenre(selectedGenreId);
//     setState(() => selectedGenreId = genreId);
//   }

//   Future<void> _fetchFilteredWithGenre(int? genreId) async {
//     setState(() => isLoading = true);
//     // TODO: trigger a fetch with the genreId
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Discover')),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 8),

//             // Search field
//             TextField(
//               decoration: const InputDecoration(
//                 labelText: 'Search manga...',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: _onSearchChanged,
//             ),

//             const SizedBox(height: 8),

//             // Genre filter pills — uses hardcoded _kSampleGenres until the API
//             // genres arrive, then switches to the live list.
//             SizedBox(
//               height: 40,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: FilterChip(
//                       label: const Text('All'),
//                       selected: selectedGenreId == null,
//                       onSelected: (_) => _onGenreChanged(null),
//                     ),
//                   ),
//                   ...(genres.isNotEmpty ? genres : _kSampleGenres).map((g) {
//                     final id = g['mal_id'] as int;
//                     final name = g['name'] as String;
//                     return Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: FilterChip(
//                         label: Text(name),
//                         selected: selectedGenreId == id,
//                         onSelected: (_) =>
//                             _onGenreChanged(selectedGenreId == id ? null : id),
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 8),

//             // TODO: render manga list
//             Expanded(
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text('Manga list will appear here'),
//                     const SizedBox(height: 16),

//                     // Stub: remove once list is implemented
//                     GestureDetector(
//                       onTap: () => context.go(
//                         '/viewer',
//                         extra:
//                             'assets/images/placeholder.jpg', // Continue uses the tall placeholder image for actual implementation for full image page
//                       ),
//                       child: const Text(
//                         'Tap to test image viewer →',
//                         style: TextStyle(
//                           color: Colors.indigo,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// presentation/screens/discover.screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mangatrack/src/core/utils/debouncer.dart';
import 'package:mangatrack/src/features/discover/presentation/providers/discover_provider.dart';
import 'package:mangatrack/src/features/discover/presentation/widgets/genre_pill.widget.dart';
import 'package:mangatrack/src/features/discover/presentation/widgets/manga_card.widget.dart';
import 'package:mangatrack/src/features/favourite/presentation/providers/favourite_provider.dart';
import 'package:mangatrack/src/routing/routes/app_route.router.dart';
import 'package:mangatrack/src/routing/routes/routes.router.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  // ← StatefulWidget → ConsumerStatefulWidget
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _debouncer = Debouncer(milliseconds: 500);

  // ↓ removed: _kSampleGenres, genres, mangaList, isLoading,
  //            searchQuery, selectedGenreId, currentPage, hasReachedEnd
  //   all state now lives in DiscoverState via discoverProvider

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // ↓ removed: _loadInitialData() — provider build() handles this
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
        // ↓ replaced: AppBar(title: Text('Discover'))
        //   with inline search field (mirrors existing TextField but in AppBar)
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search manga...',
            border: InputBorder.none,
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
          // ↓ replaced: _onSearchChanged → debounced notifier.search
          onChanged: (query) => _debouncer.run(() => notifier.search(query)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // genre pills
            // ↓ replaced: hardcoded _kSampleGenres fallback + manual FilterChip loop
            //   now uses GenrePills widget fed by state.genres from API
            if (state.genres.isNotEmpty) ...[
              GenrePills(
                genres: state.genres,
                selectedGenreIds: state.selectedGenreIds,
                onToggle: notifier.toggleGenre,
              ),
              const SizedBox(height: 8),
            ],

            // manga list
            // ↓ replaced: placeholder Text('Manga list will appear here')
            //   now uses full _buildBody
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
    // initial load
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // error with retry
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

    // empty state
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

    // manga list with pagination footer
    return RefreshIndicator(
      onRefresh: () async => notifier.refresh(),
      child: ListView.separated(
        controller: _scrollController,
        // ↓ removed: GestureDetector stub → replaced with real MangaCard list
        itemCount: state.mangaList.length + 1, // +1 for footer
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == state.mangaList.length) {
            return _buildFooter(state);
          }

          final manga = state.mangaList[index];

          return MangaCard(
            manga: manga,
            isFavourited: favouriteIds.contains(manga.malId),
            onFavouriteTap: () =>
                ref.read(favouriteProvider.notifier).toggleFavourite(manga),
            // ↓ replaced: context.go('/viewer', extra: 'assets/images/placeholder.jpg')
            //   now uses real manga imageUrl
            onTap: () => {},
            // context.push(AppRoute.imageViewer.path, extra: manga.imageUrl),
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
