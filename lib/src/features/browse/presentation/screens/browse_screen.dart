// import 'package:flutter/material.dart';

// import '../../../../services/jikan_service.dart';

// class BrowseScreen extends StatefulWidget {
//   const BrowseScreen({super.key});

//   @override
//   State<BrowseScreen> createState() => _BrowseScreenState();
// }

// class _BrowseScreenState extends State<BrowseScreen> {
//   List<dynamic> genres = [];
//   List<dynamic> mangaList = [];
//   Map<String, List<dynamic>> groupedByGenre = {};
//   bool isBrowseLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchBrowseData();
//   }

//   Future<void> _fetchBrowseData() async {
//     // 1. Fetch genres
//     final genreResponse = await JikanService.fetchGenres();
//     setState(() {
//       genres = (genreResponse['data'] as List<dynamic>?) ?? [];
//     });

//     // 2. Fetch manga pages
//     List<dynamic> allManga = [];

//     final res = await JikanService.fetchManga(page: 1, limit: 100);
//     final pageData = (res['data'] as List<dynamic>?) ?? [];
//     allManga.addAll(pageData);

//     // TODO: filter genres to only those with manga, and fetch more pages if needed to get a good sample of manga for each genre

//     // TODO: Group by  genre

//     setState(() {
//       mangaList = allManga;
//       groupedByGenre = {};
//       isBrowseLoading = false;
//     });

//     debugPrint('[Browse] Manga loaded: ${mangaList.length}');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Browse')),
//       body: const Center(
//         // TODO: build two-panel genre browser layout (can refer to ZUS coffee app for inspiration)
//         child: Text('Genre browser will appear here.'),
//       ),
//     );
//   }
// }

// features/browse/presentation/screens/browse.screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangatrack/src/features/browse/presentation/providers/browse_manga_provider.dart';
import 'package:mangatrack/src/features/browse/presentation/providers/browse_provider.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';
import 'package:mangatrack/src/features/favourite/presentation/providers/favourite_provider.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _rightPanelController = ScrollController();
  final _leftPanelController = ScrollController();
  final List<GlobalKey> _sectionKeys = [];
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _rightPanelController.addListener(_onRightPanelScroll);
  }

  @override
  void dispose() {
    _rightPanelController.dispose();
    _leftPanelController.dispose();
    super.dispose();
  }

  void _onRightPanelScroll() {
    if (_isProgrammaticScroll) return;
    _syncActiveGenreFromScroll();
  }

  void _syncActiveGenreFromScroll() {
    if (_sectionKeys.isEmpty) return;
    final activeIndex = ref.read(browseActiveGenreProvider);

    for (int i = _sectionKeys.length - 1; i >= 0; i--) {
      final key = _sectionKeys[i];
      final ctx = key.currentContext;
      if (ctx == null) continue;

      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;

      final position = box.localToGlobal(Offset.zero);
      if (position.dy <= MediaQuery.of(context).size.height * 0.35) {
        if (activeIndex != i) {
          ref.read(browseActiveGenreProvider.notifier).setIndex(i);
          _scrollLeftPanelToIndex(i);
        }
        break;
      }
    }
  }

  void _scrollLeftPanelToIndex(int index) {
    if (!_leftPanelController.hasClients) return;
    const itemHeight = 48.0;
    final offset =
        (index * itemHeight) -
        (_leftPanelController.position.viewportDimension / 2) +
        (itemHeight / 2);

    _leftPanelController.animateTo(
      offset.clamp(0, _leftPanelController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _scrollToGenre(int index) async {
    final key = _sectionKeys[index];
    final ctx = key.currentContext;
    if (ctx == null) return;

    _isProgrammaticScroll = true;
    ref.read(browseActiveGenreProvider.notifier).setIndex(index);

    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.0,
    );

    await Future.delayed(const Duration(milliseconds: 450));
    _isProgrammaticScroll = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(browseProvider);
    final activeIndex = ref.watch(browseActiveGenreProvider);

    if (_sectionKeys.length != state.activeGenres.length) {
      _sectionKeys.clear();
      for (int i = 0; i < state.activeGenres.length; i++) {
        _sectionKeys.add(GlobalKey());
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
        // ← subtle linear indicator at bottom of AppBar while loading more
        bottom: state.isLoadingMore
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(), // ← thin bar, not blocking
              )
            : null,
      ),
      body: _buildBody(state, activeIndex),
    );
  }

  Widget _buildBody(BrowseState state, int activeIndex) {
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
              onPressed: () => ref
                  .read(browseMangaProvider.notifier)
                  .retry(), // ← retry manga fetch
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.activeGenres.isEmpty) {
      return const Center(child: Text('No genres available'));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftPanel(state, activeIndex),
        const VerticalDivider(width: 1),
        Expanded(child: _buildRightPanel(state)),
      ],
    );
  }

  Widget _buildLeftPanel(BrowseState state, int activeIndex) {
    return SizedBox(
      width: 110,
      child: ListView.builder(
        controller: _leftPanelController,
        itemCount: state.activeGenres.length,
        itemExtent: 48,
        itemBuilder: (context, index) {
          final genre = state.activeGenres[index];
          final isActive = activeIndex == index; // ← uses StateProvider

          return GestureDetector(
            onTap: () => _scrollToGenre(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                genre,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRightPanel(BrowseState state) {
    final favouriteIds = ref.watch(
      favouriteProvider.select((s) => s.favouriteIds),
    );

    return CustomScrollView(
      controller: _rightPanelController,
      slivers: [
        for (int i = 0; i < state.activeGenres.length; i++) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _GenreHeaderDelegate(
              genre: state.activeGenres[i],
              sectionKey: _sectionKeys[i],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final manga = state.mangaByGenre[state.activeGenres[i]]![index];
                return _buildMangaRow(manga, favouriteIds);
              },
              childCount:
                  state.mangaByGenre[state.activeGenres[i]]?.length ?? 0,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMangaRow(MangaEntity manga, Set<int> favouriteIds) {
    final isFav = favouriteIds.contains(manga.malId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: manga.imageUrl != null
                ? Image.network(
                    manga.imageUrl!,
                    width: 48,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 68,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 20),
                    ),
                  )
                : Container(width: 48, height: 68, color: Colors.grey.shade200),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manga.title ?? 'Unknown',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (manga.score != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '${manga.score}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                ref.read(favouriteProvider.notifier).toggleFavourite(manga),
            child: Icon(
              isFav ? Icons.star : Icons.star_outline,
              color: isFav ? Colors.amber : Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String genre;
  final GlobalKey sectionKey;

  const _GenreHeaderDelegate({required this.genre, required this.sectionKey});

  @override
  double get minExtent => 40;
  @override
  double get maxExtent => 40;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      key: sectionKey,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Text(
        genre,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_GenreHeaderDelegate old) => old.genre != genre;
}
