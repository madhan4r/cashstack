import '../../../core/error/failure.dart';
import '../../../shared/models/paginated_response.dart';
import '../models/app_notification.dart';

enum NotificationsListStatus {
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

/// State for [NotificationsController] — same shape as
/// `TransactionsListState`, for the same reason: infinite scroll needs
/// "have data AND loading more" that a plain `AsyncValue` can't represent.
class NotificationsListState {
  final List<AppNotification> items;
  final PaginationMeta? meta;
  final NotificationsListStatus status;
  final Failure? error;
  final Failure? backgroundError;

  const NotificationsListState({
    this.items = const [],
    this.meta,
    this.status = NotificationsListStatus.loading,
    this.error,
    this.backgroundError,
  });

  bool get hasMore => meta == null || meta!.hasNextPage;

  bool get isInitialLoading =>
      status == NotificationsListStatus.loading && items.isEmpty;

  bool get isEmpty => status == NotificationsListStatus.loaded && items.isEmpty;

  int get unreadCount => items.where((n) => !n.read).length;

  NotificationsListState copyWith({
    List<AppNotification>? items,
    PaginationMeta? meta,
    NotificationsListStatus? status,
    Failure? error,
    bool clearError = false,
    Failure? backgroundError,
    bool clearBackgroundError = false,
  }) {
    return NotificationsListState(
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
