import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/summary_report.dart';
import 'animated_counter.dart';

/// A single KPI card for the Reports Dashboard's top row (Total Income,
/// Total Expense, Net Savings, Savings Rate) — an icon, label, and an
/// animated counter for the value.
class SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final String Function(double) formatter;
  final IconData icon;
  final Color? color;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.formatter,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.primary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Icon(icon, size: 18, color: tint),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedCounter(
            value: value,
            formatter: formatter,
            style: context.textStyles.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// 2x2 grid of [SummaryCard]s for Total Income / Total Expense / Net
/// Savings / Savings Rate.
class ReportSummaryGrid extends StatelessWidget {
  final SummaryReport summary;
  final String currencySymbol;

  const ReportSummaryGrid({
    super.key,
    required this.summary,
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
        SummaryCard(
          label: 'Total Income',
          value: summary.totalIncome,
          formatter: (v) => '$currencySymbol${v.toAmount()}',
          icon: Icons.arrow_downward_rounded,
          color: semantic.income,
        ),
        SummaryCard(
          label: 'Total Expense',
          value: summary.totalExpense,
          formatter: (v) => '$currencySymbol${v.toAmount()}',
          icon: Icons.arrow_upward_rounded,
          color: semantic.expense,
        ),
        SummaryCard(
          label: 'Net Savings',
          value: summary.netSavings,
          formatter: (v) => '$currencySymbol${v.toAmount()}',
          icon: Icons.savings_outlined,
          color: summary.netSavings >= 0 ? semantic.success : semantic.danger,
        ),
        SummaryCard(
          label: 'Savings Rate',
          value: summary.savingsRate,
          formatter: (v) => '${v.toStringAsFixed(1)}%',
          icon: Icons.percent_rounded,
        ),
      ],
    );
  }
}
