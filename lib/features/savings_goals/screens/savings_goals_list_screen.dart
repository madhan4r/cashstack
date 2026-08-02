import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/misc/app_fab.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../providers/savings_goals_list_controller.dart';
import '../widgets/savings_goal_card.dart';

class SavingsGoalsListScreen extends ConsumerWidget {
  const SavingsGoalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savingsGoalsListControllerProvider);
    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);

    return Scaffold(
      appBar: const CashStackAppBar(title: 'Savings Goals', showBackButton: false),
      body: RefreshIndicator(
        onRefresh: () => ref.read(savingsGoalsListControllerProvider.notifier).refresh(),
        child: switch (state.status) {
          SavingsGoalsListStatus.loading => const Center(child: CircularProgressIndicator()),
          SavingsGoalsListStatus.error => ScrollableSingleChild(
              child: ErrorState.fromFailure(
                state.error ?? const UnknownFailure(),
                onRetry: () => ref.read(savingsGoalsListControllerProvider.notifier).refresh(),
              ),
            ),
          _ when state.items.isEmpty => ScrollableSingleChild(
              child: EmptyState(
                icon: Icons.savings_outlined,
                title: 'No savings goals yet',
                description: 'Set a target and track your progress toward it.',
                actionLabel: 'Add Savings Goal',
                onAction: () => context.push(AppRoutes.addSavingsGoal),
              ),
            ),
          _ => ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final goal = state.items[index];
                return SavingsGoalCard(
                  goal: goal,
                  currencySymbol: currencySymbol,
                  onTap: () => context.push(AppRoutes.savingsGoalDetails(goal.id)),
                );
              },
            ),
        },
      ),
      floatingActionButton: AppFab(
        onPressed: () => context.push(AppRoutes.addSavingsGoal),
      ),
    );
  }
}
