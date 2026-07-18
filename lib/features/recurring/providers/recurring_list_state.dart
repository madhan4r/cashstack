import '../../../core/error/failure.dart';
import '../models/recurring_transaction.dart';

enum RecurringListStatus { loading, refreshing, loaded, error }

/// State for [RecurringListController]. The backend returns the full,
/// unpaginated list for a given filter/sort in one call.
class RecurringListState {
  final List<RecurringTransaction> items;
  final RecurringListStatus status;
  final Failure? error;

  const RecurringListState({
    this.items = const [],
    this.status = RecurringListStatus.loading,
    this.error,
  });

  bool get isInitialLoading => status == RecurringListStatus.loading && items.isEmpty;

  RecurringListState copyWith({
    List<RecurringTransaction>? items,
    RecurringListStatus? status,
    Failure? error,
    bool clearError = false,
  }) {
    return RecurringListState(
      items: items ?? this.items,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
