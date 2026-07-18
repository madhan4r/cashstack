import '../../../core/error/failure.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/history_occurrence.dart';

enum HistoryStatus { loading, loadingMore, refreshing, loaded, error }

class HistoryState {
  final List<HistoryOccurrence> items;
  final PaginationMeta? meta;
  final HistoryStatus status;
  final Failure? error;

  const HistoryState({
    this.items = const [],
    this.meta,
    this.status = HistoryStatus.loading,
    this.error,
  });

  bool get hasMore => meta == null || meta!.hasNextPage;
  bool get isInitialLoading => status == HistoryStatus.loading && items.isEmpty;
  bool get isEmpty => status == HistoryStatus.loaded && items.isEmpty;

  HistoryState copyWith({
    List<HistoryOccurrence>? items,
    PaginationMeta? meta,
    HistoryStatus? status,
    Failure? error,
    bool clearError = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
