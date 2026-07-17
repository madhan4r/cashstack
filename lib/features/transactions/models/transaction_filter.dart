import 'package:equatable/equatable.dart';

import '../../../shared/models/transaction_kind.dart';
import 'transaction_sort_option.dart';

/// Everything needed to query `GET /transactions`: the debounced search
/// text, the filter-sheet selections, and the current sort. A single
/// immutable value so [TransactionsListController] can watch it and
/// refetch whenever any part of it changes.
class TransactionFilter extends Equatable {
  final String search;
  final TransactionKind? type;
  final String? categoryId;
  final String? accountId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final double? minAmount;
  final double? maxAmount;
  final TransactionSortOption sort;

  const TransactionFilter({
    this.search = '',
    this.type,
    this.categoryId,
    this.accountId,
    this.fromDate,
    this.toDate,
    this.minAmount,
    this.maxAmount,
    this.sort = TransactionSortOption.newest,
  });

  /// True if any filter-sheet field is set (search/sort don't count — the
  /// filter icon badge reflects the sheet's own fields only).
  bool get hasActiveFilters =>
      type != null ||
      categoryId != null ||
      accountId != null ||
      fromDate != null ||
      toDate != null ||
      minAmount != null ||
      maxAmount != null;

  TransactionFilter copyWith({
    String? search,
    TransactionKind? type,
    bool clearType = false,
    String? categoryId,
    bool clearCategoryId = false,
    String? accountId,
    bool clearAccountId = false,
    DateTime? fromDate,
    bool clearFromDate = false,
    DateTime? toDate,
    bool clearToDate = false,
    double? minAmount,
    bool clearMinAmount = false,
    double? maxAmount,
    bool clearMaxAmount = false,
    TransactionSortOption? sort,
  }) {
    return TransactionFilter(
      search: search ?? this.search,
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      sort: sort ?? this.sort,
    );
  }

  /// Resets every filter-sheet field, keeping search and sort as-is.
  TransactionFilter clearFilters() {
    return TransactionFilter(search: search, sort: sort);
  }

  Map<String, dynamic> toQueryParameters({required int page, required int limit}) {
    return {
      'page': page,
      'limit': limit,
      'sort': sort.queryValue,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (type != null) 'type': type!.toJson(),
      if (categoryId != null) 'category': categoryId,
      if (accountId != null) 'account': accountId,
      if (fromDate != null) 'fromDate': _dateOnly(fromDate!),
      if (toDate != null) 'toDate': _dateOnly(toDate!),
      if (minAmount != null) 'minAmount': minAmount,
      if (maxAmount != null) 'maxAmount': maxAmount,
    };
  }

  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [
    search,
    type,
    categoryId,
    accountId,
    fromDate,
    toDate,
    minAmount,
    maxAmount,
    sort,
  ];
}
