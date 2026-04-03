class MangaEntity {
  final int malId;
  final String? title;
  final String? titleEnglish;
  final String? imageUrl;
  final String? synopsis;
  final String? status;
  final int? chapters;
  final int? volumes;
  final double? score;
  final int? scoredBy;
  final int? rank;
  final List<String> genres;

  const MangaEntity({
    required this.malId,
    this.title,
    this.titleEnglish,
    this.imageUrl,
    this.synopsis,
    this.status,
    this.chapters,
    this.volumes,
    this.score,
    this.scoredBy,
    this.rank,
    this.genres = const [],
  });
}
