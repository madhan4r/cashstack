import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../shared/models/transaction_kind.dart';
import '../models/upcoming_occurrence.dart';

/// A list of upcoming scheduled transactions — used by the Recurring list
/// screen's "Upcoming" tab.
class SchedulePreview extends StatelessWidget {
  final List<UpcomingOccurrence> entries;
  final String currencySymbol;

  /// Resolves the currency symbol for one entry's own account — takes
  /// precedence over [currencySymbol] when provided, since a list spanning
  /// several accounts (e.g. the list screen's "Upcoming" tab) can't use one
  /// flat symbol for everything. The form screen's live preview omits this
  /// (every entry there is for the single account currently being
  /// configured) and just uses [currencySymbol].
  final String Function(UpcomingOccurrence entry)? symbolFor;

  const SchedulePreview({
    super.key,
    required this.entries,
    this.currencySymbol = '\$',
    this.symbolFor,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(
            child: Text(
              'No upcoming transactions in this window',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _PreviewRow(
              entry: entries[i],
              currencySymbol: symbolFor?.call(entries[i]) ?? currencySymbol,
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final UpcomingOccurrence entry;
  final String currencySymbol;

  const _PreviewRow({required this.entry, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final isExpense = entry.type == TransactionKind.expense;

    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.event_repeat_rounded, color: context.colors.primary, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.name,
                style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                entry.dueDate.toRelativeLabel(),
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          isExpense
              ? '-$currencySymbol${entry.amount.toAmount()}'
              : '+$currencySymbol${entry.amount.toAmount()}',
          style: context.textStyles.labelMedium?.copyWith(
            color: isExpense ? semantic.expense : semantic.income,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
