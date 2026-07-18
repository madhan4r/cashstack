import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';

/// Income vs. Expense as two side-by-side bars for the active period.
class BarChartCard extends StatelessWidget {
  final double income;
  final double expense;
  final String currencySymbol;

  const BarChartCard({
    super.key,
    required this.income,
    required this.expense,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final maxValue = income > expense ? income : expense;
    final maxY = maxValue <= 0 ? 100.0 : maxValue * 1.25;

    return AppCard(
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: context.colors.outlineVariant.withValues(alpha: 0.4),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final label = value.toInt() == 0 ? 'Income' : 'Expense';
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        label,
                        style: context.textStyles.labelMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => context.colors.inverseSurface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '$currencySymbol${rod.toY.toAmount()}',
                    TextStyle(
                      color: groupIndex == 0 ? semantic.income : semantic.expense,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: income,
                    color: semantic.income,
                    width: 40,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: expense,
                    color: semantic.expense,
                    width: 40,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ],
          ),
          duration: const Duration(milliseconds: 500),
        ),
      ),
    );
  }
}
