import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/category_spending.dart';

/// "Top spending categories" — each row is an icon, name, progress bar,
/// percentage, and amount.
class AnalyticsCard extends StatelessWidget {
  final List<CategorySpending> categories;
  final String currencySymbol;

  const AnalyticsCard({
    super.key,
    required this.categories,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _CategoryProgressRow(
              category: categories[i],
              currencySymbol: currencySymbol,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryProgressRow extends StatelessWidget {
  final CategorySpending category;
  final String currencySymbol;

  const _CategoryProgressRow({
    required this.category,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final tint = colorFromHex(
      category.categoryColor,
      fallback: context.colors.primary,
    );
    final icon = categoryIconFor(category.categoryIcon);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: tint, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.categoryName,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$currencySymbol${category.total.toAmount()}',
                    style: context.textStyles.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppRadius.radiusPill,
                      child: LinearProgressIndicator(
                        value: (category.percentage / 100).clamp(0, 1),
                        minHeight: 6,
                        backgroundColor: tint.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(tint),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${category.percentage.toStringAsFixed(0)}%',
                      style: context.textStyles.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
