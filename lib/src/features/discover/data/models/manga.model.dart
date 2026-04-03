class MangaModel {
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

  const MangaModel({
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

  factory MangaModel.fromJson(Map<String, dynamic> json) {
    final images = json['images']?['jpg'] as Map<String, dynamic>?;
    final genreList =
        (json['genres'] as List?) // ← List? not List<dynamic>
            ?.map((e) => e['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList() ??
        [];

    return MangaModel(
      malId: json['mal_id'] as int? ?? 0, // ← guard every field
      title: json['title'] as String?,
      titleEnglish: json['title_english'] as String?,
      imageUrl: images?['image_url'] as String?,
      synopsis: json['synopsis'] as String?,
      status: json['status'] as String?,
      chapters: json['chapters'] as int?,
      volumes: json['volumes'] as int?,
      score: (json['score'] as num?)?.toDouble(),
      scoredBy: json['scored_by'] as int?,
      rank: json['rank'] as int?,
      genres: genreList,
    );
  }

  Map<String, dynamic> toJson() => {
    'mal_id': malId,
    'title': title,
    'title_english': titleEnglish,
    'images': {
      'jpg': {'image_url': imageUrl},
    },
    'synopsis': synopsis,
    'status': status,
    'chapters': chapters,
    'volumes': volumes,
    'score': score,
    'scored_by': scoredBy,
    'rank': rank,
    'genres': genres.map((e) => {'name': e}).toList(),
  };
}
