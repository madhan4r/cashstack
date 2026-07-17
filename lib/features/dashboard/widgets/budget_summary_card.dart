import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';

/// Budget vs. spent for the current month, with a progress indicator.
///
/// There is no Budgets module on the backend yet, so [budget] is `null`
/// until one exists — in that case this renders a "no budget set" prompt
/// instead of a fabricated progress bar. Once a real budget/limit value is
/// available, pass it in and the full progress view renders.
class BudgetSummaryCard extends StatelessWidget {
  final double? budget;
  final double spent;
  final String currencySymbol;
  final VoidCallback? onSetBudget;

  const BudgetSummaryCard({
    super.key,
    required this.budget,
    required this.spent,
    this.currencySymbol = '\$',
    this.onSetBudget,
  });

  @override
  Widget build(BuildContext context) {
    final budget = this.budget;

    if (budget == null || budget <= 0) {
      return AppCard(
        onTap: onSetBudget,
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline_rounded,
                color: context.colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No budget set',
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Set a monthly budget to track your spending here.',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colors.onSurfaceVariant),
          ],
        ),
      );
    }

    final remaining = budget - spent;
    final progress = (spent / budget).clamp(0, 1).toDouble();
    final isOverBudget = spent > budget;
    final progressColor = isOverBudget
        ? context.semanticColors.danger
        : context.colors.primary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BudgetStat(label: 'Budget', value: budget, currencySymbol: currencySymbol),
              _BudgetStat(label: 'Spent', value: spent, currencySymbol: currencySymbol),
              _BudgetStat(
                label: 'Remaining',
                value: remaining,
                currencySymbol: currencySymbol,
                valueColor: isOverBudget ? context.semanticColors.danger : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.radiusPill,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: progressColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  final String label;
  final double value;
  final String currencySymbol;
  final Color? valueColor;

  const _BudgetStat({
    required this.label,
    required this.value,
    required this.currencySymbol,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$currencySymbol${value.toAmount()}',
          style: context.textStyles.titleSmall?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
