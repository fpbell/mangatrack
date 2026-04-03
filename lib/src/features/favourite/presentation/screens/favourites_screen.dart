// features/favourite/presentation/screens/favourites.screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mangatrack/src/features/favourite/presentation/providers/favourite_provider.dart';
import 'package:mangatrack/src/features/favourite/presentation/widgets/favourite_card.widget.dart';
import 'package:mangatrack/src/routing/routes/app_route.router.dart';
import 'package:mangatrack/src/routing/routes/routes.router.dart';

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
    // loading from storage
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // empty state
    // ↓ replaces: placeholder Text('Your favourite manga will be shown here.')
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
              'Start exploring and bookmark manga you love!',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // favourites list
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.favourites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final manga = state.favourites[index];
        return FavouriteCard(
          manga: manga,
          onRemove: () =>
              ref.read(favouriteProvider.notifier).toggleFavourite(manga),
          onTap: () => {},
          // context.push(AppRoute.imageViewer.path, extra: manga.imageUrl),
        );
      },
    );
  }
}
