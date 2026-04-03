// features/favourite/presentation/widgets/favourite_card.widget.dart
import 'package:flutter/material.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';

class FavouriteCard extends StatelessWidget {
  final MangaEntity manga;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const FavouriteCard({
    super.key,
    required this.manga,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // cover image
            SizedBox(
              width: 80,
              height: 110,
              child: manga.imageUrl != null
                  ? Image.network(
                      manga.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    )
                  : const Icon(Icons.image_not_supported),
            ),
            const SizedBox(width: 12),
            // info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga.title ?? 'Unknown title',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (manga.score != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Score: ${manga.score}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // remove button
            IconButton(
              icon: const Icon(Icons.bookmark, color: Colors.indigo),
              onPressed: onRemove,
              tooltip: 'Remove from favourites',
            ),
          ],
        ),
      ),
    );
  }
}
