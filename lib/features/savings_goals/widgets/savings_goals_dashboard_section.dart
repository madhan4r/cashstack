import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/misc/section_header.dart';
import '../../../routes/app_routes.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../providers/savings_goals_list_controller.dart';
import 'savings_goal_card.dart';

const _maxShown = 2;

/// Dashboard section showing the top couple of savings goals — renders
/// nothing while loading/empty/errored, since the Dashboard already has a
/// lot going on and this is a "nice to have" glance, not critical data.
class SavingsGoalsDashboardSection extends ConsumerWidget {
  const SavingsGoalsDashboardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savingsGoalsListControllerProvider);
    if (state.items.isEmpty) return const SizedBox.shrink();

    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);
    final shown = state.items.take(_maxShown).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Savings Goals',
          actionLabel: state.items.length > _maxShown ? 'See All' : null,
          onAction: () => context.push(AppRoutes.savingsGoals),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final goal in shown) ...[
          SavingsGoalCard(
            goal: goal,
            currencySymbol: currencySymbol,
            onTap: () => context.push(AppRoutes.savingsGoalDetails(goal.id)),
          ),
          if (goal != shown.last) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
