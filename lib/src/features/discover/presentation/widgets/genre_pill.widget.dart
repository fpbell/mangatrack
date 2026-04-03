// presentation/widgets/genre_pill.widget.dart
import 'package:flutter/material.dart';
import 'package:mangatrack/src/features/discover/domain/entities/genre.entity.dart';

class GenrePills extends StatelessWidget {
  final List<GenreEntity> genres;
  final List<int> selectedGenreIds; // ← List<int>
  final ValueChanged<int> onToggle; // ← toggle instead of select

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

          return FilterChip(
            label: Text(genre.name),
            selected: isSelected,
            onSelected: (_) => onToggle(genre.malId), // ← toggle
          );
        },
      ),
    );
  }
}
