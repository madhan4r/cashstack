import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../models/recurring_filter.dart';
import '../repositories/recurring_repository.dart';
import 'recurring_filter_provider.dart';
import 'recurring_list_state.dart';

/// Drives the Recurring list: re-fetches whenever
/// [recurringFilterProvider] changes (status/frequency/sort), plus
/// pull-to-refresh. Each fetch also triggers the backend's on-read
/// catch-up (see `RecurringService.catchUp` on the backend), so due
/// schedules generate/miss their occurrence before the list renders.
class RecurringListController extends Notifier<RecurringListState> {
  RecurringFilter? _filterForCurrentState;

  @override
  RecurringListState build() {
    final filter = ref.watch(recurringFilterProvider);
    _filterForCurrentState = filter;
    unawaited(_load(filter));
    return const RecurringListState();
  }

  Future<void> _load(RecurringFilter filter) async {
    final repository = ref.read(recurringRepositoryProvider);
    try {
      final items = await repository.getRecurring(filter);
      if (!_isCurrent(filter)) return;
      state = state.copyWith(
        items: items,
        status: RecurringListStatus.loaded,
        clearError: true,
      );
    } catch (error) {
      if (!_isCurrent(filter)) return;
      state = state.copyWith(
        status: RecurringListStatus.error,
        error: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> refresh() async {
    final filter = _filterForCurrentState ?? const RecurringFilter();
    state = state.copyWith(status: RecurringListStatus.refreshing);
    await _load(filter);
  }

  bool _isCurrent(RecurringFilter filter) => _filterForCurrentState == filter;
}

final recurringListControllerProvider =
    NotifierProvider<RecurringListController, RecurringListState>(
      RecurringListController.new,
    );
