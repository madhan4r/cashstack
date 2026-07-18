import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../transactions/models/transaction_filter.dart';
import '../../transactions/models/transaction_sort_option.dart';
import '../../transactions/providers/transactions_list_state.dart';
import '../../transactions/repositories/transactions_repository.dart';

const _pageSize = 20;

/// Paginated transaction history for a single account's Details screen.
/// Deliberately separate from [TransactionsListController] — that one is
/// wired to the global [transactionFilterProvider] driving the Transactions
/// tab's search/sort/filter UI, and reusing it here would let this screen's
/// account scoping leak into (or be overwritten by) that global state.
/// Reuses the same [TransactionsListState]/[TransactionFilter] shapes and
/// the existing `TransactionsRepository.getTransactions` call, just scoped
/// by a fixed `accountId` that never changes for a given family instance.
class AccountTransactionsController extends Notifier<TransactionsListState> {
  final String accountId;

  AccountTransactionsController(this.accountId);

  TransactionFilter get _filter =>
      TransactionFilter(accountId: accountId, sort: TransactionSortOption.newest);

  @override
  TransactionsListState build() {
    unawaited(_loadFirstPage());
    return const TransactionsListState();
  }

  Future<void> _loadFirstPage() async {
    final repository = ref.read(transactionsRepositoryProvider);
    try {
      final result = await repository.getTransactions(
        filter: _filter,
        page: 1,
        limit: _pageSize,
      );
      state = state.copyWith(
        items: result.items,
        meta: result.meta,
        status: TransactionsListStatus.loaded,
        clearError: true,
      );
    } catch (error) {
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

    state = state.copyWith(status: TransactionsListStatus.loadingMore);
    final repository = ref.read(transactionsRepositoryProvider);
    final nextPage = (state.meta?.page ?? 0) + 1;

    try {
      final result = await repository.getTransactions(
        filter: _filter,
        page: nextPage,
        limit: _pageSize,
      );
      state = state.copyWith(
        items: [...state.items, ...result.items],
        meta: result.meta,
        status: TransactionsListStatus.loaded,
      );
    } catch (error) {
      state = state.copyWith(
        status: TransactionsListStatus.loaded,
        backgroundError: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: TransactionsListStatus.refreshing);
    final repository = ref.read(transactionsRepositoryProvider);

    try {
      final result = await repository.getTransactions(
        filter: _filter,
        page: 1,
        limit: _pageSize,
      );
      state = state.copyWith(
        items: result.items,
        meta: result.meta,
        status: TransactionsListStatus.loaded,
        clearError: true,
        clearBackgroundError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: TransactionsListStatus.loaded,
        backgroundError: mapExceptionToFailure(error),
      );
    }
  }

  void dismissBackgroundError() {
    state = state.copyWith(clearBackgroundError: true);
  }
}

final accountTransactionsControllerProvider = NotifierProvider.autoDispose
    .family<AccountTransactionsController, TransactionsListState, String>(
      AccountTransactionsController.new,
    );
