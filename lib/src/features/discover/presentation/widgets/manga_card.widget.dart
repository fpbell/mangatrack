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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image with star overlay
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // cover image
                  manga.imageUrl != null
                      ? Image.network(
                          manga.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                          ),
                        ),

                  // ← star icon top right on image
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onFavouriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isFavourited ? Colors.orange : Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavourited ? Icons.star : Icons.star_outline,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ← title outside below the image
          const SizedBox(height: 6),
          Text(
            manga.title ?? 'Unknown',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
