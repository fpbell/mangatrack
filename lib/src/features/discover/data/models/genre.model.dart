// features/discover/data/models/genre.model.dart
class GenreModel {
  final int malId;
  final String name;
  final int count;

  const GenreModel({
    required this.malId,
    required this.name,
    required this.count,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) => GenreModel(
    malId: json['mal_id'] as int,
    name: json['name'] as String,
    count: json['count'] as int? ?? 0,
  );
}
