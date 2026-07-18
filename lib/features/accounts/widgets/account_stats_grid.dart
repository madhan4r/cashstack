import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/cards/stat_card.dart';
import '../models/account_stats.dart';

/// Total Income / Total Expense / Net Balance / Transaction Count for the
/// Account Details screen, laid out as a 2x2 grid of [StatCard]s.
class AccountStatsGrid extends StatelessWidget {
  final AccountStats stats;
  final String currencySymbol;

  const AccountStatsGrid({
    super.key,
    required this.stats,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.7,
      children: [
        StatCard(
          label: 'Total Income',
          value: '$currencySymbol${stats.totalIncome.toAmount()}',
          icon: Icons.arrow_downward_rounded,
          color: semantic.income,
        ),
        StatCard(
          label: 'Total Expense',
          value: '$currencySymbol${stats.totalExpense.toAmount()}',
          icon: Icons.arrow_upward_rounded,
          color: semantic.expense,
        ),
        StatCard(
          label: 'Net Balance',
          value: '$currencySymbol${stats.netBalance.toAmount()}',
          icon: Icons.account_balance_wallet_outlined,
        ),
        StatCard(
          label: 'Transactions',
          value: '${stats.transactionCount}',
          icon: Icons.receipt_long_outlined,
        ),
      ],
    );
  }
}
