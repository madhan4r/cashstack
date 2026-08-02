import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/category_budget.dart';

class CategoryBudgetTile extends StatelessWidget {
  final CategoryBudget budget;
  final String currencySymbol;
  final VoidCallback onTap;

  const CategoryBudgetTile({
    super.key,
    required this.budget,
    required this.currencySymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tint = colorFromHex(budget.categoryColor, fallback: context.colors.primary);
    final progressColor = budget.isOverBudget ? context.semanticColors.danger : tint;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(categoryIconFor(budget.categoryIcon), color: tint, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  budget.categoryName,
                  style: context.textStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$currencySymbol${budget.spent.toStringAsFixed(0)} / $currencySymbol${budget.amount.toStringAsFixed(0)}',
                style: context.textStyles.bodySmall?.copyWith(
                  color: budget.isOverBudget
                      ? context.semanticColors.danger
                      : context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.radiusPill,
            child: LinearProgressIndicator(
              value: budget.progress.toDouble(),
              minHeight: 6,
              backgroundColor: progressColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}
