import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../shared/models/transaction_kind.dart';
import '../models/detected_transaction.dart';

class DetectedTransactionTile extends StatelessWidget {
  final DetectedTransaction transaction;
  final String currencySymbol;
  final VoidCallback onAdd;
  final VoidCallback onDismiss;

  const DetectedTransactionTile({
    super.key,
    required this.transaction,
    required this.currencySymbol,
    required this.onAdd,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionKind.expense;
    final semantic = context.semanticColors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: (isExpense ? semantic.expense : semantic.income).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpense ? Icons.south_west_rounded : Icons.north_east_rounded,
                  color: isExpense ? semantic.expense : semantic.income,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isExpense ? 'Possible expense detected' : 'Possible income detected',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      transaction.detectedAt.toRelativeLabel(),
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isExpense ? '-' : '+'}$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                style: context.textStyles.titleSmall?.copyWith(
                  color: isExpense ? semantic.expense : semantic.income,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            transaction.rawText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: onDismiss, child: const Text('Dismiss')),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(onPressed: onAdd, child: const Text('Add Transaction')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
