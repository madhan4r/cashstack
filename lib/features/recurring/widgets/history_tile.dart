import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/history_occurrence.dart';
import '../models/occurrence_status.dart';

/// A single row on the History tab — a generated or missed occurrence.
class HistoryTile extends StatelessWidget {
  final HistoryOccurrence occurrence;
  final String currencySymbol;

  const HistoryTile({super.key, required this.occurrence, this.currencySymbol = '\$'});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final isGenerated = occurrence.status == OccurrenceStatus.generated;
    final tint = isGenerated ? semantic.success : semantic.danger;

    return AppCard(
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(color: tint.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(
              isGenerated ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
              color: tint,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  occurrence.name,
                  style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${occurrence.status.label} • ${occurrence.dueDate.toMediumDate()}',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$currencySymbol${occurrence.amount.toAmount()}',
            style: context.textStyles.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
