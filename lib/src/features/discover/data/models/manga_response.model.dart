import 'manga.model.dart';

class MangaResponseModel {
  final List<MangaModel> data;
  final PaginationModel pagination;

  const MangaResponseModel({required this.data, required this.pagination});

  factory MangaResponseModel.fromJson(Map<String, dynamic> json) {
    return MangaResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => MangaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}

class PaginationModel {
  final int lastVisiblePage;
  final bool hasNextPage;
  final int currentPage;
  final int count;

  const PaginationModel({
    required this.lastVisiblePage,
    required this.hasNextPage,
    required this.currentPage,
    required this.count,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as Map<String, dynamic>?;
    return PaginationModel(
      lastVisiblePage: json['last_visible_page'] as int,
      hasNextPage: json['has_next_page'] as bool,
      currentPage: json['current_page'] as int,
      count: items?['count'] as int? ?? 0,
    );
  }
}
