import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../models/recurring_status.dart';

/// Small filled pill showing a recurring schedule's Active/Paused/
/// Completed status.
class StatusChip extends StatelessWidget {
  final RecurringStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final color = switch (status) {
      RecurringStatus.active => semantic.success,
      RecurringStatus.paused => semantic.warning,
      RecurringStatus.completed => context.colors.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: context.textStyles.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
