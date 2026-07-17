import '../../../core/error/failure.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/transaction.dart';

enum TransactionsListStatus {
  /// First page hasn't loaded yet.
  loading,

  /// Have data; fetching the next page to append.
  loadingMore,

  /// Have data; pull-to-refresh is re-fetching page 1.
  refreshing,

  /// Have data (possibly empty), nothing in flight.
  loaded,

  /// The *first* page failed — there's nothing to show behind it.
  error,
}

/// State for [TransactionsListController]. Deliberately not a plain
/// `AsyncValue<List<Transaction>>` — infinite scroll needs "have data AND
/// loading more" and "have data AND a background refresh failed" states
/// that a single `AsyncValue` can't represent cleanly.
class TransactionsListState {
  final List<Transaction> items;
  final PaginationMeta? meta;
  final TransactionsListStatus status;
  final Failure? error;

  /// Set when a *background* refresh/load-more fails, without discarding
  /// the items already on screen. The screen surfaces this as a snackbar
  /// rather than replacing the list with an error state.
  final Failure? backgroundError;

  const TransactionsListState({
    this.items = const [],
    this.meta,
    this.status = TransactionsListStatus.loading,
    this.error,
    this.backgroundError,
  });

  bool get hasMore => meta == null || meta!.hasNextPage;

  bool get isInitialLoading =>
      status == TransactionsListStatus.loading && items.isEmpty;

  bool get isEmpty => status == TransactionsListStatus.loaded && items.isEmpty;

  TransactionsListState copyWith({
    List<Transaction>? items,
    PaginationMeta? meta,
    TransactionsListStatus? status,
    Failure? error,
    bool clearError = false,
    Failure? backgroundError,
    bool clearBackgroundError = false,
  }) {
    return TransactionsListState(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      backgroundError: clearBackgroundError
          ? null
          : (backgroundError ?? this.backgroundError),
    );
  }
}
