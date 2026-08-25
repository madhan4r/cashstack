import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/misc/app_fab.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/misc/section_header.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../models/categories_filter.dart';
import '../models/category.dart';
import '../models/category_type.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class CategoriesListScreen extends ConsumerStatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  ConsumerState<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen> {
  bool _isSearching = false;

  void _toggleSearch() {
    setState(() => _isSearching = !_isSearching);
    if (!_isSearching) {
      ref.read(categoriesFilterProvider.notifier).updateSearch('');
    }
  }

  void _onTapCategory(Category category) {
    context.push(AppRoutes.categoryDetails(category.id));
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(categoriesListControllerProvider);
    final filter = ref.watch(categoriesFilterProvider);
    final categories = ref.watch(filteredCategoriesProvider);
    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);
    final hasActiveFilters = filter.type != null || filter.search.isNotEmpty;

    return Scaffold(
      appBar: CashStackAppBar(
        title: _isSearching ? null : 'Categories',
        titleWidget: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search categories',
                  border: InputBorder.none,
                ),
                onChanged: (value) =>
                    ref.read(categoriesFilterProvider.notifier).updateSearch(value),
              )
            : null,
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            tooltip: _isSearching ? 'Close search' : 'Search',
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: _FilterChipsRow(filter: filter),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(categoriesListControllerProvider.notifier).refresh(),
              child: switch (listState.status) {
                CategoriesListStatus.loading => const ScrollableSingleChild(
                    child: CategoriesSkeleton(),
                  ),
                CategoriesListStatus.error => ScrollableSingleChild(
                    child: ErrorState.fromFailure(
                      listState.error ?? const UnknownFailure(),
                      onRetry: () =>
                          ref.read(categoriesListControllerProvider.notifier).refresh(),
                    ),
                  ),
                _ when categories.isEmpty => ScrollableSingleChild(
                    child: CategoriesEmptyState(
                      hasActiveFilters: hasActiveFilters,
                      onClearFilters: hasActiveFilters
                          ? () {
                              ref.read(categoriesFilterProvider.notifier)
                                ..updateSearch('')
                                ..setType(null);
                              if (_isSearching) _toggleSearch();
                            }
                          : null,
                      onAddCategory: () => context.push(AppRoutes.addCategory),
                    ),
                  ),
                _ => _GroupedCategoryList(
                    categories: categories,
                    currencySymbol: currencySymbol,
                    onTapCategory: _onTapCategory,
                  ),
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AppFab(
        onPressed: () => context.push(AppRoutes.addCategory),
      ),
    );
  }
}

class _FilterChipsRow extends ConsumerWidget {
  final CategoriesFilter filter;

  const _FilterChipsRow({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Expense'),
            selected: filter.type == CategoryType.expense,
            onSelected: (selected) => ref
                .read(categoriesFilterProvider.notifier)
                .setType(selected ? CategoryType.expense : null),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilterChip(
            label: const Text('Income'),
            selected: filter.type == CategoryType.income,
            onSelected: (selected) => ref
                .read(categoriesFilterProvider.notifier)
                .setType(selected ? CategoryType.income : null),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilterChip(
            label: const Text('Active'),
            selected: !filter.showArchived,
            onSelected: (_) =>
                ref.read(categoriesFilterProvider.notifier).setShowArchived(false),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilterChip(
            label: const Text('Archived'),
            selected: filter.showArchived,
            onSelected: (_) =>
                ref.read(categoriesFilterProvider.notifier).setShowArchived(true),
          ),
        ],
      ),
    );
  }
}

class _GroupedCategoryList extends StatelessWidget {
  final List<Category> categories;
  final String currencySymbol;
  final ValueChanged<Category> onTapCategory;

  const _GroupedCategoryList({
    required this.categories,
    required this.currencySymbol,
    required this.onTapCategory,
  });

  @override
  Widget build(BuildContext context) {
    final expense = categories.where((c) => c.type == CategoryType.expense).toList();
    final income = categories.where((c) => c.type == CategoryType.income).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (expense.isNotEmpty) ...[
          const SectionHeader(title: 'Expense'),
          const SizedBox(height: AppSpacing.sm),
          for (final category in expense)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: CategoryCard(
                category: category,
                currencySymbol: currencySymbol,
                onTap: () => onTapCategory(category),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (income.isNotEmpty) ...[
          const SectionHeader(title: 'Income'),
          const SizedBox(height: AppSpacing.sm),
          for (final category in income)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: CategoryCard(
                category: category,
                currencySymbol: currencySymbol,
                onTap: () => onTapCategory(category),
              ),
            ),
        ],
      ],
    );
  }
}
