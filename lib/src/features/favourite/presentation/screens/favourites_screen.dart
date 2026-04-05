// features/favourite/presentation/screens/favourites.screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mangatrack/src/features/favourite/presentation/providers/favourite_provider.dart';
import 'package:mangatrack/src/features/favourite/presentation/widgets/favourite_card.widget.dart'; // ← import

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favouriteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, FavouriteState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.favourites.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No favourites yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Start exploring!',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final manga = state.favourites[index];
              return FavouriteCard(
                // ← use extracted widget
                manga: manga,
                onRemove: () =>
                    ref.read(favouriteProvider.notifier).toggleFavourite(manga),
                onTap: () => context.push(
                  '/viewer',
                  extra: {
                    'imageUrl': manga.largeImageUrl ?? manga.imageUrl ?? '',
                    'title': manga.title ?? 'Image Viewer',
                  },
                ),
              );
            }, childCount: state.favourites.length),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '${state.favourites.length} manga saved',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
