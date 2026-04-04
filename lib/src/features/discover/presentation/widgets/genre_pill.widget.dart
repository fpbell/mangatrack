// presentation/widgets/genre_pill.widget.dart
import 'package:flutter/material.dart';
import 'package:mangatrack/src/features/discover/domain/entities/genre.entity.dart';

class GenrePills extends StatelessWidget {
  final List<GenreEntity> genres;
  final List<int> selectedGenreIds;
  final ValueChanged<int> onToggle;

  const GenrePills({
    super.key,
    required this.genres,
    required this.selectedGenreIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = selectedGenreIds.contains(genre.malId);

          // ← GestureDetector wraps Container, not inside it
          return GestureDetector(
            onTap: () => onToggle(genre.malId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                genre.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight:
                      isSelected // ← this will now work correctly
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
