import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_filter.dart';
import '../models/transaction_sort_option.dart';

/// The active search/filter/sort state. [TransactionsListController]
/// watches this and refetches page 1 whenever it changes.
class TransactionFilterController extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  /// Applies the debounced search text — see `TransactionsSearchBar`.
  void updateSearch(String search) {
    state = state.copyWith(search: search);
  }

  void updateSort(TransactionSortOption sort) {
    state = state.copyWith(sort: sort);
  }

  /// Replaces every filter-sheet field in one go (the sheet's "Apply").
  void applyFilters(TransactionFilter next) {
    state = next;
  }

  void clearFilters() {
    state = state.clearFilters();
  }
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterController, TransactionFilter>(
      TransactionFilterController.new,
    );
