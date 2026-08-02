import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/inputs/search_text_field.dart';
import '../models/category_selector_item.dart';
import '../providers/category_preferences_provider.dart';
import 'category_grid.dart';

/// The reusable Category Selector: search, then (while not searching)
/// Favorites and Recently Used shortcuts sourced from
/// [categoryPreferencesProvider], then the full grid. Used both by
/// [showCategorySelectorSheet] and inline wherever a scoped category list
/// needs picking from (e.g. the Add/Edit Transaction form).
class CategorySelector extends ConsumerStatefulWidget {
  final List<CategorySelectorItem> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelected;

  /// When provided, shows an "Add new category" row so the user can
  /// create one without leaving whatever screen opened this selector
  /// (e.g. the transaction form) — `null` hides it entirely.
  final VoidCallback? onCreateNew;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.onSelected,
    this.selectedCategoryId,
    this.onCreateNew,
  });

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(categoryPreferencesProvider);
    final categoriesById = {for (final c in widget.categories) c.id: c};

    final filtered = _query.trim().isEmpty
        ? widget.categories
        : widget.categories
            .where((c) => c.name.toLowerCase().contains(_query.trim().toLowerCase()))
            .toList();

    final isSearching = _query.trim().isNotEmpty;
    final favorites = preferences.favoriteIds
        .map((id) => categoriesById[id])
        .whereType<CategorySelectorItem>()
        .toList();
    final recents = preferences.recentIds
        .where((id) => !preferences.favoriteIds.contains(id))
        .map((id) => categoriesById[id])
        .whereType<CategorySelectorItem>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchTextField(
          hint: 'Search categories',
          onChanged: (value) => setState(() => _query = value),
        ),
        if (widget.onCreateNew != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _AddNewCategoryButton(onTap: widget.onCreateNew!),
        ],
        const SizedBox(height: AppSpacing.md),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSearching && favorites.isNotEmpty) ...[
                  Text('Favorites', style: context.textStyles.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: CategoryGrid(
                      categories: favorites,
                      selectedCategoryId: widget.selectedCategoryId,
                      favoriteIds: preferences.favoriteIds.toSet(),
                      onSelected: _handleSelected,
                      onToggleFavorite: _handleToggleFavorite,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (!isSearching && recents.isNotEmpty) ...[
                  Text('Recent', style: context.textStyles.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  CategoryGrid(
                    categories: recents,
                    selectedCategoryId: widget.selectedCategoryId,
                    favoriteIds: preferences.favoriteIds.toSet(),
                    onSelected: _handleSelected,
                    onToggleFavorite: _handleToggleFavorite,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Text(
                  isSearching ? 'Results' : 'All categories',
                  style: context.textStyles.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: filtered.isEmpty
                      ? Padding(
                          key: const ValueKey('empty'),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          child: Center(
                            child: Text(
                              'No categories found',
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      : CategoryGrid(
                          key: ValueKey('grid-${filtered.length}-$_query'),
                          categories: filtered,
                          selectedCategoryId: widget.selectedCategoryId,
                          favoriteIds: preferences.favoriteIds.toSet(),
                          onSelected: _handleSelected,
                          onToggleFavorite: _handleToggleFavorite,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleSelected(String categoryId) {
    ref.read(categoryPreferencesProvider.notifier).recordUsed(categoryId);
    widget.onSelected(categoryId);
  }

  void _handleToggleFavorite(String categoryId) {
    ref.read(categoryPreferencesProvider.notifier).toggleFavorite(categoryId);
  }
}

class _AddNewCategoryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNewCategoryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Add new category'),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
    );
  }
}
