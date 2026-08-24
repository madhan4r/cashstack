import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../shared/models/transaction_kind.dart';
import '../models/recurring_status.dart';
import '../models/recurring_transaction.dart';
import 'status_chip.dart';

/// A single row on the Recurring list — name, amount, category, account,
/// frequency, next due date, and status, with swipe actions for Pause/
/// Resume/Delete.
class RecurringCard extends StatelessWidget {
  final RecurringTransaction recurring;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? accountName;
  final String currencySymbol;
  final VoidCallback? onTap;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onDelete;

  const RecurringCard({
    super.key,
    required this.recurring,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.accountName,
    this.currencySymbol = '\$',
    this.onTap,
    this.onPause,
    this.onResume,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tint = colorFromHex(categoryColor, fallback: context.colors.primary);
    final semantic = context.semanticColors;
    final isExpense = recurring.type == TransactionKind.expense;

    return Slidable(
      key: ValueKey(recurring.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: recurring.status == RecurringStatus.completed ? 0.25 : 0.5,
        children: [
          if (recurring.status == RecurringStatus.active)
            SlidableAction(
              onPressed: (_) => onPause?.call(),
              backgroundColor: semantic.warning,
              foregroundColor: Colors.white,
              icon: Icons.pause_rounded,
              label: 'Pause',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            ),
          if (recurring.status == RecurringStatus.paused)
            SlidableAction(
              onPressed: (_) => onResume?.call(),
              backgroundColor: semantic.success,
              foregroundColor: Colors.white,
              icon: Icons.play_arrow_rounded,
              label: 'Resume',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: semantic.danger,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            borderRadius: BorderRadius.horizontal(
              right: const Radius.circular(20),
              left: recurring.status == RecurringStatus.completed
                  ? const Radius.circular(20)
                  : Radius.zero,
            ),
          ),
        ],
      ),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(categoryIconFor(categoryIcon), color: tint, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recurring.name,
                        style: context.textStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        [?categoryName, ?accountName].join(' • '),
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  isExpense
                      ? '-$currencySymbol${recurring.amount.toAmount()}'
                      : '+$currencySymbol${recurring.amount.toAmount()}',
                  style: context.textStyles.titleSmall?.copyWith(
                    color: isExpense ? semantic.expense : semantic.income,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _MetaChip(icon: Icons.repeat_rounded, label: recurring.frequency.label),
                const SizedBox(width: AppSpacing.sm),
                _DueDateChip(recurring: recurring),
                const Spacer(),
                StatusChip(status: recurring.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The due-date chip, colored by urgency for an active schedule: overdue
/// (danger), due within [_dueSoonWindow] (warning), otherwise the same
/// neutral styling as every other meta chip. Paused/completed schedules
/// don't have a "live" countdown, so they stay neutral regardless of how
/// close `nextDueDate` looks.
class _DueDateChip extends StatelessWidget {
  static const _dueSoonWindow = Duration(days: 3);

  final RecurringTransaction recurring;

  const _DueDateChip({required this.recurring});

  @override
  Widget build(BuildContext context) {
    if (recurring.status == RecurringStatus.completed) {
      return const _MetaChip(icon: Icons.event_outlined, label: 'Ended');
    }

    final label = 'Due ${recurring.nextDueDate.toRelativeLabel()}';
    if (recurring.status != RecurringStatus.active) {
      return _MetaChip(icon: Icons.event_outlined, label: label);
    }

    final now = DateTime.now();
    final semantic = context.semanticColors;
    if (recurring.nextDueDate.isBefore(now)) {
      return _MetaChip(
        icon: Icons.error_outline_rounded,
        label: label,
        color: semantic.danger,
      );
    }
    if (recurring.nextDueDate.isBefore(now.add(_dueSoonWindow))) {
      return _MetaChip(
        icon: Icons.schedule_rounded,
        label: label,
        color: semantic.warning,
      );
    }
    return _MetaChip(icon: Icons.event_outlined, label: label);
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.12) ?? context.colors.surfaceContainerHighest,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tint),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(color: tint),
          ),
        ],
      ),
    );
  }
}
