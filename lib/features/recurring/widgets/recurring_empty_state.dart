import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/empty_state.dart';

/// Shown when the Recurring list has nothing to display.
class RecurringEmptyState extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;
  final VoidCallback? onAdd;

  const RecurringEmptyState({
    super.key,
    required this.hasActiveFilters,
    this.onClearFilters,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (hasActiveFilters) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matching schedules',
        description: 'Try a different filter.',
        actionLabel: onClearFilters == null ? null : 'Clear filters',
        onAction: onClearFilters,
      );
    }

    return EmptyState(
      icon: Icons.event_repeat_outlined,
      title: 'No recurring transactions yet',
      description:
          'Automate bills, subscriptions, and salary so you never have to add them manually.',
      actionLabel: onAdd == null ? null : 'Create Recurring Transaction',
      onAction: onAdd,
    );
  }
}
