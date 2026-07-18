import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/daily_breakdown_item.dart';

/// Daily Spending — one column per day's expense total within the active
/// window.
class ColumnChartCard extends StatelessWidget {
  final List<DailyBreakdownItem> days;
  final String currencySymbol;

  const ColumnChartCard({
    super.key,
    required this.days,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final maxExpense = days.fold<double>(0, (max, d) => d.expense > max ? d.expense : max);
    final maxY = maxExpense <= 0 ? 100.0 : maxExpense * 1.25;
    // Thin out x-axis labels once there are too many days to fit legibly.
    final labelStep = (days.length / 8).ceil().clamp(1, days.length);

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
                  reservedSize: 24,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= days.length || index % labelStep != 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${days[index].day}',
                        style: context.textStyles.labelSmall?.copyWith(
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
                    TextStyle(color: semantic.expense, fontWeight: FontWeight.w600),
                  );
                },
              ),
            ),
            barGroups: [
              for (var i = 0; i < days.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: days[i].expense,
                      color: semantic.expense,
                      width: days.length > 20 ? 6 : 12,
                      borderRadius: BorderRadius.circular(4),
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
