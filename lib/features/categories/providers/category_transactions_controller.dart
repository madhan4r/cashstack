import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../transactions/models/transaction_filter.dart';
import '../../transactions/models/transaction_sort_option.dart';
import '../../transactions/providers/transactions_list_state.dart';
import '../../transactions/repositories/transactions_repository.dart';

const _pageSize = 20;

/// Paginated transaction history for a single category's Detail screen.
/// Mirrors `AccountTransactionsController` — reuses the existing
/// [TransactionsListState]/[TransactionFilter] shapes and
/// `TransactionsRepository.getTransactions`, scoped by a fixed
/// `categoryId` rather than the global transactions-tab filter.
class CategoryTransactionsController extends Notifier<TransactionsListState> {
  final String categoryId;

  CategoryTransactionsController(this.categoryId);

  TransactionFilter get _filter =>
      TransactionFilter(categoryId: categoryId, sort: TransactionSortOption.newest);

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

final categoryTransactionsControllerProvider = NotifierProvider.autoDispose
    .family<CategoryTransactionsController, TransactionsListState, String>(
      CategoryTransactionsController.new,
    );
