import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/category.dart';

/// A single row on the Categories list — icon, name, color accent,
/// transaction count, and (when non-zero) total amount. Purely
/// presentational.
class CategoryCard extends StatelessWidget {
  final Category category;
  final String currencySymbol;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.currencySymbol = '\$',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tint = colorFromHex(category.color, fallback: context.colors.primary);

    return Opacity(
      opacity: category.isArchived ? 0.6 : 1,
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(categoryIconFor(category.icon), color: tint, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: context.textStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (category.isDefault) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified_outlined,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.transactionCount} '
                    '${category.transactionCount == 1 ? 'transaction' : 'transactions'}'
                    '${category.isArchived ? ' • Archived' : ''}',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (category.totalAmount > 0) ...[
              const SizedBox(width: 8),
              Text(
                '$currencySymbol${category.totalAmount.toAmount()}',
                style: context.textStyles.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
