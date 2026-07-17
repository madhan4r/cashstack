import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/empty_state.dart';

/// Shown when the current search/filter combination matches nothing.
/// Copy adapts depending on whether any filter is actually active, so a
/// brand-new user (no filters) and a too-narrow search both get relevant
/// guidance.
class TransactionsEmptyState extends StatelessWidget {
  final bool hasActiveSearchOrFilters;
  final VoidCallback? onClearFilters;
  final VoidCallback? onAddTransaction;

  const TransactionsEmptyState({
    super.key,
    required this.hasActiveSearchOrFilters,
    this.onClearFilters,
    this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    if (hasActiveSearchOrFilters) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matching transactions',
        description: 'Try adjusting your search or filters.',
        actionLabel: onClearFilters == null ? null : 'Clear filters',
        onAction: onClearFilters,
      );
    }

    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No transactions yet',
      description: 'Add your first transaction to see it here.',
      actionLabel: onAddTransaction == null ? null : 'Add Transaction',
      onAction: onAddTransaction,
    );
  }
}
