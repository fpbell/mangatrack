// features/discover/domain/entities/genre.entity.dart
class GenreEntity {
  final int malId;
  final String name;
  final int count;

  const GenreEntity({
    required this.malId,
    required this.name,
    required this.count,
  });
}
