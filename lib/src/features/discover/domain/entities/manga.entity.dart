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

  Map<String, dynamic> toJson() => {
    'mal_id': malId,
    'title': title,
    'title_english': titleEnglish,
    'image_url': imageUrl,
    'synopsis': synopsis,
    'status': status,
    'chapters': chapters,
    'volumes': volumes,
    'score': score,
    'scored_by': scoredBy,
    'rank': rank,
    'genres': genres,
  };

  factory MangaEntity.fromJson(Map<String, dynamic> json) => MangaEntity(
    malId: json['mal_id'] as int,
    title: json['title'] as String?,
    titleEnglish: json['title_english'] as String?,
    imageUrl: json['image_url'] as String?,
    synopsis: json['synopsis'] as String?,
    status: json['status'] as String?,
    chapters: json['chapters'] as int?,
    volumes: json['volumes'] as int?,
    score: (json['score'] as num?)?.toDouble(),
    scoredBy: json['scored_by'] as int?,
    rank: json['rank'] as int?,
    genres: (json['genres'] as List?)?.map((e) => e.toString()).toList() ?? [],
  );
}
