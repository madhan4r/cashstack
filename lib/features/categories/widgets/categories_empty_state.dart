import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/empty_state.dart';

/// Shown when the Categories list has nothing to display. Copy adapts to
/// whether search/filters are narrowing an otherwise non-empty list, vs. a
/// brand-new user with no custom categories yet.
class CategoriesEmptyState extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;
  final VoidCallback? onAddCategory;

  const CategoriesEmptyState({
    super.key,
    required this.hasActiveFilters,
    this.onClearFilters,
    this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (hasActiveFilters) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matching categories',
        description: 'Try a different search term or filter.',
        actionLabel: onClearFilters == null ? null : 'Clear filters',
        onAction: onClearFilters,
      );
    }

    return EmptyState(
      icon: Icons.category_outlined,
      title: 'No categories yet',
      description: 'Add a custom category to organize your transactions.',
      actionLabel: onAddCategory == null ? null : 'Add Category',
      onAction: onAddCategory,
    );
  }
}
