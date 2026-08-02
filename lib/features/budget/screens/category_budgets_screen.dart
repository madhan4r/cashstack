import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/misc/app_fab.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../providers/category_budgets_controller.dart';
import '../widgets/category_budget_tile.dart';
import '../widgets/set_category_budget_sheet.dart';

class CategoryBudgetsScreen extends ConsumerWidget {
  const CategoryBudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryBudgetsControllerProvider);
    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);

    return Scaffold(
      appBar: const CashStackAppBar(title: 'Category Budgets'),
      body: RefreshIndicator(
        onRefresh: () => ref.read(categoryBudgetsControllerProvider.notifier).refresh(),
        child: switch (state.status) {
          CategoryBudgetsStatus.loading => const Center(child: CircularProgressIndicator()),
          CategoryBudgetsStatus.error => ScrollableSingleChild(
              child: ErrorState.fromFailure(
                state.error ?? const UnknownFailure(),
                onRetry: () => ref.read(categoryBudgetsControllerProvider.notifier).refresh(),
              ),
            ),
          _ when state.items.isEmpty => ScrollableSingleChild(
              child: EmptyState(
                icon: Icons.pie_chart_outline_rounded,
                title: 'No category budgets yet',
                description: 'Set a monthly spending limit for individual categories.',
                actionLabel: 'Add Category Budget',
                onAction: () =>
                    showSetCategoryBudgetSheet(context: context, currencySymbol: currencySymbol),
              ),
            ),
          _ => ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final budget = state.items[index];
                return CategoryBudgetTile(
                  budget: budget,
                  currencySymbol: currencySymbol,
                  onTap: () => showSetCategoryBudgetSheet(
                    context: context,
                    currencySymbol: currencySymbol,
                    existing: budget,
                  ),
                );
              },
            ),
        },
      ),
      floatingActionButton: AppFab(
        onPressed: () =>
            showSetCategoryBudgetSheet(context: context, currencySymbol: currencySymbol),
      ),
    );
  }
}
