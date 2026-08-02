import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../models/reports_data.dart';
import 'insight_card.dart';

/// Top Insights: highest spending category, largest transaction, average
/// daily spending, transaction count, most used account, most used
/// category.
class InsightsGrid extends StatelessWidget {
  final ReportsData data;
  final String currencySymbol;

  const InsightsGrid({super.key, required this.data, this.currencySymbol = '\$'});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final highestCategory = data.highestSpendingCategory;
    final mostUsedAccount = data.mostUsedAccount;
    final mostUsedCategory = data.mostUsedCategory;
    final largestTransaction = data.largestTransaction;

    final cards = [
      InsightCard(
        label: 'Highest Spending Category',
        value: highestCategory == null
            ? '—'
            : '${highestCategory.categoryName} • $currencySymbol${highestCategory.amount.toAmount()}',
        icon: Icons.local_fire_department_outlined,
        color: semantic.expense,
      ),
      InsightCard(
        label: 'Largest Transaction',
        value: largestTransaction == null
            ? '—'
            : '$currencySymbol${largestTransaction.amount.toAmount()}',
        icon: Icons.trending_up_rounded,
      ),
      InsightCard(
        label: 'Average Daily Spending',
        value: '$currencySymbol${data.averageDailySpending.toAmount()}',
        icon: Icons.calendar_today_outlined,
      ),
      InsightCard(
        label: 'Transactions',
        value: '${data.summary.transactionCount}',
        icon: Icons.receipt_long_outlined,
      ),
      InsightCard(
        label: 'Most Used Account',
        value: mostUsedAccount?.accountName ?? '—',
        icon: Icons.account_balance_wallet_outlined,
      ),
      InsightCard(
        label: 'Most Used Category',
        value: mostUsedCategory?.categoryName ?? '—',
        icon: Icons.category_outlined,
      ),
    ];

    // A GridView forces every cell to a fixed height (via childAspectRatio),
    // which overflows as soon as a label wraps to more lines than that
    // ratio assumed (e.g. "Highest Spending Category" on a narrow column,
    // or a larger system font-scale setting). A Wrap of fixed-width cards
    // lets each one size to its own content height instead.
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final card in cards) SizedBox(width: cellWidth, child: card),
          ],
        );
      },
    );
  }
}
