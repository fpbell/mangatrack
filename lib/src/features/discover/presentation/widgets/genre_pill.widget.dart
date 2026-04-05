import 'package:flutter/material.dart';
import 'package:mangatrack/src/features/discover/domain/entities/genre.entity.dart';

class GenrePills extends StatelessWidget {
  final List<GenreEntity> genres;
  final int? selectedGenreId;
  final ValueChanged<int> onSelect;

  const GenrePills({
    super.key,
    required this.genres,
    required this.selectedGenreId,
    required this.onSelect,
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
          final isSelected = selectedGenreId == genre.malId;

          return GestureDetector(
            onTap: () => onSelect(genre.malId),
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
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
