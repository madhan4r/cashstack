import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/category_breakdown_item.dart';

/// Category / Amount / Percentage / Progress Bar rows, already sorted by
/// highest spending first (the backend returns them that way). Optionally
/// enriched with icon/color via [iconOf]/[colorOf] (looked up from the
/// caller's categories cache — the report response itself has no
/// icon/color, only id/name).
class CategoryBreakdownList extends StatelessWidget {
  final List<CategoryBreakdownItem> items;
  final String currencySymbol;
  final String? Function(String categoryId)? iconOf;
  final String? Function(String categoryId)? colorOf;
  final ValueChanged<CategoryBreakdownItem>? onTap;

  const CategoryBreakdownList({
    super.key,
    required this.items,
    this.currencySymbol = '\$',
    this.iconOf,
    this.colorOf,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _CategoryRow(
              item: items[i],
              currencySymbol: currencySymbol,
              icon: iconOf?.call(items[i].categoryId),
              color: colorOf?.call(items[i].categoryId),
              onTap: onTap == null ? null : () => onTap!(items[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryBreakdownItem item;
  final String currencySymbol;
  final String? icon;
  final String? color;
  final VoidCallback? onTap;

  const _CategoryRow({
    required this.item,
    required this.currencySymbol,
    this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tint = colorFromHex(color, fallback: context.colors.primary);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(categoryIconFor(icon), color: tint, size: 18),
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
                      item.categoryName,
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$currencySymbol${item.amount.toAmount()}',
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
                          value: (item.percentage / 100).clamp(0, 1),
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
                        '${item.percentage.toStringAsFixed(0)}%',
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
      ),
    );
  }
}
