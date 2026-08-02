import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/misc/section_header.dart';
import '../../../routes/app_routes.dart';
import '../../auth/providers/auth_controller.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../../budget/widgets/set_budget_sheet.dart';
import '../models/dashboard_data.dart';
import '../providers/dashboard_controller.dart';
import '../widgets/analytics_card.dart';
import '../widgets/balance_card.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/dashboard_transaction_tile.dart';
import '../widgets/monthly_trend_chart_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/staggered_entrance.dart';

const _maxContentWidth = 640.0;
const _sectionGap = SizedBox(height: AppSpacing.xl);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final userName = ref.watch(authControllerProvider).user?.fullName;
    final currencySymbol = ref.watch(preferredCurrencySymbolProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: switch (dashboardAsync) {
                AsyncData(:final value) => value.hasNoActivity
                    ? _EmptyDashboard(header: DashboardHeader(fullName: userName))
                    : _DashboardContent(
                        data: value,
                        header: DashboardHeader(fullName: userName),
                        currencySymbol: currencySymbol,
                      ),
                AsyncError(:final error) => ScrollableSingleChild(
                    child: ErrorState.fromFailure(
                      error is Failure ? error : const UnknownFailure(),
                      onRetry: () => ref.invalidate(dashboardControllerProvider),
                    ),
                  ),
                _ => const DashboardSkeleton(),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  final Widget header;

  const _EmptyDashboard({required this.header});

  @override
  Widget build(BuildContext context) {
    return ScrollableSingleChild(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            header,
            const SizedBox(height: AppSpacing.xxxl),
            EmptyState(
              icon: Icons.savings_outlined,
              title: 'Start tracking your finances',
              description:
                  'Add your first transaction to see your balance, spending, and trends here.',
              actionLabel: 'Add First Transaction',
              onAction: () => context.push(AppRoutes.addTransaction),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardData data;
  final Widget header;
  final String currencySymbol;

  const _DashboardContent({
    required this.data,
    required this.header,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        header,
        _sectionGap,
        StaggeredEntrance(
          child: BalanceCard(
            currentBalance: data.currentBalance,
            monthlyIncome: data.monthlyIncome,
            monthlyExpense: data.monthlyExpense,
            monthlySavings: data.monthlySavings,
            currencySymbol: currencySymbol,
          ),
        ),
        _sectionGap,
        StaggeredEntrance(
          delay: const Duration(milliseconds: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: AppSpacing.md),
              QuickActionsGrid(
                items: [
                  QuickActionItem(
                    label: 'Add Expense',
                    icon: Icons.remove_circle_outline_rounded,
                    color: context.semanticColors.expense,
                    onTap: () => context.push('${AppRoutes.addTransaction}?type=EXPENSE'),
                  ),
                  QuickActionItem(
                    label: 'Add Income',
                    icon: Icons.add_circle_outline_rounded,
                    color: context.semanticColors.income,
                    onTap: () => context.push('${AppRoutes.addTransaction}?type=INCOME'),
                  ),
                  QuickActionItem(
                    label: 'Transfer',
                    icon: Icons.swap_horiz_rounded,
                    onTap: () => context.push('${AppRoutes.addTransaction}?type=TRANSFER'),
                  ),
                  QuickActionItem(
                    label: 'Reports',
                    icon: Icons.bar_chart_rounded,
                    onTap: () => context.push(AppRoutes.reports),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (data.expenseByCategory.isNotEmpty) ...[
          _sectionGap,
          StaggeredEntrance(
            delay: const Duration(milliseconds: 160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Top Spending Categories'),
                const SizedBox(height: AppSpacing.md),
                AnalyticsCard(
                  categories: data.expenseByCategory.take(5).toList(),
                  currencySymbol: currencySymbol,
                ),
              ],
            ),
          ),
        ],
        _sectionGap,
        StaggeredEntrance(
          delay: const Duration(milliseconds: 240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Monthly Trend'),
              const SizedBox(height: AppSpacing.md),
              MonthlyTrendChartCard(points: data.monthlyTrend),
            ],
          ),
        ),
        _sectionGap,
        StaggeredEntrance(
          delay: const Duration(milliseconds: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Budget Summary'),
              const SizedBox(height: AppSpacing.md),
              BudgetSummaryCard(
                budget: data.monthlyBudget,
                spent: data.monthlyExpense,
                currencySymbol: currencySymbol,
                onSetBudget: () => showSetBudgetSheet(
                  context: context,
                  currentAmount: data.monthlyBudget,
                  currencySymbol: currencySymbol,
                ),
              ),
            ],
          ),
        ),
        _sectionGap,
        StaggeredEntrance(
          delay: const Duration(milliseconds: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Recent Transactions',
                actionLabel: 'See All',
                onAction: () => context.push(AppRoutes.transactions),
              ),
              for (final transaction in data.recentTransactions)
                DashboardTransactionTile(
                  transaction: transaction,
                  currencySymbol: currencySymbol,
                  onTap: () => context.push(AppRoutes.editTransaction(transaction.id)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
