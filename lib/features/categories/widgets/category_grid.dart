import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../models/category_selector_item.dart';

/// The reusable grid-of-tiles layout — a [Wrap] of category tiles with a
/// smooth scale/tint animation on selection and a favorite-star badge.
/// Used directly by [CategorySelector] and by the Icon Picker's live
/// preview; pulled out on its own since the spec calls out "Category Grid"
/// and "Category Selector" as separate reusable pieces.
class CategoryGrid extends StatelessWidget {
  final List<CategorySelectorItem> categories;
  final String? selectedCategoryId;
  final Set<String> favoriteIds;
  final ValueChanged<String> onSelected;
  final ValueChanged<String>? onToggleFavorite;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.onSelected,
    this.selectedCategoryId,
    this.favoriteIds = const {},
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: categories
          .map(
            (category) => _CategoryGridItem(
              category: category,
              isSelected: category.id == selectedCategoryId,
              isFavorite: favoriteIds.contains(category.id),
              onTap: () => onSelected(category.id),
              onToggleFavorite: onToggleFavorite == null
                  ? null
                  : () => onToggleFavorite!(category.id),
            ),
          )
          .toList(),
    );
  }
}

const _itemSize = 76.0;

class _CategoryGridItem extends StatelessWidget {
  final CategorySelectorItem category;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  const _CategoryGridItem({
    required this.category,
    required this.isSelected,
    required this.isFavorite,
    required this.onTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final tint = colorFromHex(category.color, fallback: context.colors.primary);

    return SizedBox(
      width: _itemSize,
      child: InkWell(
        onTap: onTap,
        onLongPress: onToggleFavorite,
        borderRadius: AppRadius.radiusMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusMd,
            border: Border.all(
              color: isSelected ? tint : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    scale: isSelected ? 1.08 : 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? tint : tint.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        categoryIconFor(category.icon),
                        color: isSelected ? _onColor(tint) : tint,
                        size: 22,
                      ),
                    ),
                  ),
                  if (isFavorite)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: context.semanticColors.warning,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                category.name,
                style: context.textStyles.labelSmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _onColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
