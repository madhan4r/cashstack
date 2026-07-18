import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/empty_state.dart';

/// Shown when there's no transaction activity at all in the active period
/// — nothing to chart or break down.
class ReportsEmptyState extends StatelessWidget {
  final VoidCallback? onClearFilters;

  const ReportsEmptyState({super.key, this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.insights_outlined,
      title: 'Nothing to report yet',
      description: 'No transactions in this period. Try a different date range or filter.',
      actionLabel: onClearFilters == null ? null : 'Clear filters',
      onAction: onClearFilters,
    );
  }
}
