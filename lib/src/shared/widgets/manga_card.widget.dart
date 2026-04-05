import 'package:flutter/material.dart';
import 'package:mangatrack/src/features/discover/domain/entities/manga.entity.dart';

class MangaCard extends StatelessWidget {
  final MangaEntity manga;
  final bool isFavourited;
  final VoidCallback onFavouriteTap;
  final VoidCallback onTap;
  final bool useRegularImage;

  const MangaCard({
    super.key,
    required this.manga,
    required this.isFavourited,
    required this.onFavouriteTap,
    required this.onTap,
    this.useRegularImage = false,
  });

  String? get _imageUrl =>
      useRegularImage ? manga.imageUrl : manga.smallImageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _imageUrl != null
                ? Image.network(
                    _imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 40),
                  ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(8, 26, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        manga.title ?? 'Unknown',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onFavouriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isFavourited
                              ? Colors.orange.shade700
                              : Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavourited ? Icons.star : Icons.star_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
