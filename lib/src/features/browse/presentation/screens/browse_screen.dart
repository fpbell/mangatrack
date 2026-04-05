import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mangatrack/src/features/browse/presentation/providers/browse_manga_provider.dart';
import 'package:mangatrack/src/features/browse/presentation/providers/browse_provider.dart';
import 'package:mangatrack/src/features/favourite/presentation/providers/favourite_provider.dart';
import 'package:mangatrack/src/shared/widgets/manga_card.widget.dart';

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
        title: const Text(
          'Browse',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
        ),
        bottom: state.isLoadingMore
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(),
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
              onPressed: ref.read(browseMangaProvider.notifier).retry,
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
      width: 100,
      child: ListView.builder(
        controller: _leftPanelController,
        itemCount: state.activeGenres.length,
        itemExtent: 48,
        itemBuilder: (context, index) {
          final genre = state.activeGenres[index];
          final isActive = activeIndex == index;

          return GestureDetector(
            onTap: () => _scrollToGenre(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isActive ? Colors.orange.shade50 : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isActive ? Colors.orange : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                genre,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? Colors.orange.shade900 : Colors.black87,
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
    final activeIndex = ref.watch(browseActiveGenreProvider);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: Colors.orange.shade200, width: 1),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.centerLeft,
              key: ValueKey(activeIndex),
              child: Text(
                state.activeGenres.isNotEmpty
                    ? state.activeGenres[activeIndex]
                    : '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: CustomScrollView(
            controller: _rightPanelController,
            slivers: [
              for (int i = 0; i < state.activeGenres.length; i++) ...[
                SliverToBoxAdapter(
                  child: Container(
                    key: _sectionKeys[i],
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final manga =
                            state.mangaByGenre[state.activeGenres[i]]![index];
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
                              'imageUrl':
                                  manga.largeImageUrl ?? manga.imageUrl ?? '',
                              'title': manga.title ?? 'Image Viewer',
                            },
                          ),
                        );
                      },
                      childCount:
                          state.mangaByGenre[state.activeGenres[i]]?.length ??
                          0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
