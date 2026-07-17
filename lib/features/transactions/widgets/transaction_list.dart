import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/feedback/circular_loader.dart';
import '../models/account_ref.dart';
import '../models/category_ref.dart';
import '../models/transaction.dart';
import 'transaction_list_tile.dart';

const _loadMoreThreshold = 400.0;

/// Scrollable list of [TransactionListTile]s that requests the next page
/// (via [onLoadMore]) once the user scrolls within [_loadMoreThreshold]
/// pixels of the bottom, and shows a small loading indicator there while
/// [isLoadingMore] is true.
class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Map<String, CategoryRef> categoriesById;
  final Map<String, AccountRef> accountsById;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final ValueChanged<Transaction>? onTapTransaction;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.categoriesById,
    required this.accountsById,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
    this.onTapTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        final remaining = metrics.maxScrollExtent - metrics.pixels;
        if (remaining < _loadMoreThreshold && hasMore && !isLoadingMore) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: transactions.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == transactions.length) {
            return _TrailingIndicator(isLoadingMore: isLoadingMore);
          }

          final transaction = transactions[index];
          return TransactionListTile(
            transaction: transaction,
            category: categoriesById[transaction.categoryId],
            account: accountsById[transaction.accountId],
            onTap: onTapTransaction == null
                ? null
                : () => onTapTransaction!(transaction),
          );
        },
      ),
    );
  }
}

class _TrailingIndicator extends StatelessWidget {
  final bool isLoadingMore;

  const _TrailingIndicator({required this.isLoadingMore});

  @override
  Widget build(BuildContext context) {
    if (!isLoadingMore) return const SizedBox(height: AppSpacing.xl);

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(child: CircularLoader()),
    );
  }
}
