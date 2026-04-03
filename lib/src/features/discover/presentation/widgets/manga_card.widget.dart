// presentation/widgets/manga_card.widget.dart
import 'package:flutter/material.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';

class MangaCard extends StatelessWidget {
  final MangaEntity manga;
  final bool isFavourited;
  final VoidCallback onFavouriteTap;
  final VoidCallback onTap;

  const MangaCard({
    super.key,
    required this.manga,
    required this.isFavourited,
    required this.onFavouriteTap,
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
            // favourite icon
            IconButton(
              icon: Icon(
                isFavourited ? Icons.bookmark : Icons.bookmark_outline,
                color: isFavourited
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: onFavouriteTap,
            ),
          ],
        ),
      ),
    );
  }
}
