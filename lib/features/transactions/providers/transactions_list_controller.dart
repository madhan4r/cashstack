import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../models/transaction_filter.dart';
import '../repositories/transactions_repository.dart';
import 'transaction_filter_provider.dart';
import 'transactions_list_state.dart';

const _pageSize = 20;

/// Drives the transactions list: initial load, infinite scroll
/// (`loadNextPage`), and pull-to-refresh (`refresh`) — all re-triggered
/// from page 1 whenever [transactionFilterProvider] changes (search,
/// sort, or the filter sheet).
class TransactionsListController extends Notifier<TransactionsListState> {
  TransactionFilter? _filterForCurrentState;

  @override
  TransactionsListState build() {
    final filter = ref.watch(transactionFilterProvider);
    _filterForCurrentState = filter;
    unawaited(_loadFirstPage(filter));
    return const TransactionsListState();
  }

  Future<void> _loadFirstPage(TransactionFilter filter) async {
    final repository = ref.read(transactionsRepositoryProvider);

    try {
      final result = await repository.getTransactions(
        filter: filter,
        page: 1,
        limit: _pageSize,
      );
      if (!_isCurrent(filter)) return;
      state = state.copyWith(
        items: result.items,
        meta: result.meta,
        status: TransactionsListStatus.loaded,
        clearError: true,
      );
    } catch (error) {
      if (!_isCurrent(filter)) return;
      state = state.copyWith(
        status: TransactionsListStatus.error,
        error: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.status != TransactionsListStatus.loaded || !state.hasMore) {
      return;
    }

    final filter = _filterForCurrentState ?? const TransactionFilter();
    state = state.copyWith(status: TransactionsListStatus.loadingMore);

    final repository = ref.read(transactionsRepositoryProvider);
    final nextPage = (state.meta?.page ?? 0) + 1;

    try {
      final result = await repository.getTransactions(
        filter: filter,
        page: nextPage,
        limit: _pageSize,
      );
      if (!_isCurrent(filter)) return;
      state = state.copyWith(
        items: [...state.items, ...result.items],
        meta: result.meta,
        status: TransactionsListStatus.loaded,
      );
    } catch (error) {
      if (!_isCurrent(filter)) return;
      // Keep the existing items visible; surface the failure separately.
      state = state.copyWith(
        status: TransactionsListStatus.loaded,
        backgroundError: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> refresh() async {
    final filter = _filterForCurrentState ?? const TransactionFilter();
    state = state.copyWith(status: TransactionsListStatus.refreshing);

    final repository = ref.read(transactionsRepositoryProvider);

    try {
      final result = await repository.getTransactions(
        filter: filter,
        page: 1,
        limit: _pageSize,
      );
      if (!_isCurrent(filter)) return;
      state = state.copyWith(
        items: result.items,
        meta: result.meta,
        status: TransactionsListStatus.loaded,
        clearError: true,
        clearBackgroundError: true,
      );
    } catch (error) {
      if (!_isCurrent(filter)) return;
      state = state.copyWith(
        status: TransactionsListStatus.loaded,
        backgroundError: mapExceptionToFailure(error),
      );
    }
  }

  void dismissBackgroundError() {
    state = state.copyWith(clearBackgroundError: true);
  }

  /// Guards against a stale request (from a since-superseded filter)
  /// overwriting state after the user has already changed the filter
  /// again.
  bool _isCurrent(TransactionFilter filter) => _filterForCurrentState == filter;
}

final transactionsListControllerProvider =
    NotifierProvider<TransactionsListController, TransactionsListState>(
      TransactionsListController.new,
    );
