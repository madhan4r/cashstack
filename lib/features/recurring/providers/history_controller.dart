import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../models/occurrence_status.dart';
import '../repositories/recurring_repository.dart';
import 'history_state.dart';

const _pageSize = 20;

/// Paginated occurrence history for a single [OccurrenceStatus] tab
/// (Generated or Missed) on the History screen.
class HistoryController extends Notifier<HistoryState> {
  final OccurrenceStatus status;

  HistoryController(this.status);

  @override
  HistoryState build() {
    unawaited(_loadFirstPage());
    return const HistoryState();
  }

  Future<void> _loadFirstPage() async {
    final repository = ref.read(recurringRepositoryProvider);
    try {
      final result = await repository.getHistory(status: status, page: 1, limit: _pageSize);
      state = state.copyWith(
        items: result.items,
        meta: result.meta,
        status: HistoryStatus.loaded,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(status: HistoryStatus.error, error: mapExceptionToFailure(error));
    }
  }

  Future<void> loadNextPage() async {
    if (state.status != HistoryStatus.loaded || !state.hasMore) return;
    state = state.copyWith(status: HistoryStatus.loadingMore);
    final repository = ref.read(recurringRepositoryProvider);
    final nextPage = (state.meta?.page ?? 0) + 1;

    try {
      final result = await repository.getHistory(
        status: status,
        page: nextPage,
        limit: _pageSize,
      );
      state = state.copyWith(
        items: [...state.items, ...result.items],
        meta: result.meta,
        status: HistoryStatus.loaded,
      );
    } catch (error) {
      state = state.copyWith(status: HistoryStatus.loaded, error: mapExceptionToFailure(error));
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: HistoryStatus.refreshing);
    await _loadFirstPage();
  }
}

final historyControllerProvider = NotifierProvider.autoDispose
    .family<HistoryController, HistoryState, OccurrenceStatus>(HistoryController.new);
