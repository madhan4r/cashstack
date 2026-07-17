/// Mirrors the backend's `{ items, meta: { total, page, limit, totalPages } }`
/// pagination shape, used by any future feature that lists paginated data
/// (transactions, reports, etc).
class PaginatedResponse<T> {
  final List<T> items;
  final PaginationMeta meta;

  const PaginatedResponse({required this.items, required this.meta});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromItem,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List<dynamic>)
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
