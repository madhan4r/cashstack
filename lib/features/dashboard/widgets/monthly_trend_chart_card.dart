import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/monthly_trend_point.dart';

/// Income vs. expense over the last 6 months, as a dual-line chart.
class MonthlyTrendChartCard extends StatelessWidget {
  final List<MonthlyTrendPoint> points;

  const MonthlyTrendChartCard({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final maxY = points
        .expand((p) => [p.income, p.expense])
        .fold<double>(0, (max, v) => v > max ? v : max);
    // Avoid a degenerate 0-height chart when there's no income/expense yet.
    final effectiveMaxY = maxY <= 0 ? 100.0 : maxY * 1.2;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LegendDot(color: semantic.income, label: 'Income'),
              const SizedBox(width: AppSpacing.md),
              _LegendDot(color: semantic.expense, label: 'Expense'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Isolates the chart's custom painting into its own GPU layer —
          // same reasoning as BalanceCard's RepaintBoundary — so scrolling
          // past it recomposites a cached bitmap instead of re-running
          // fl_chart's paint every frame.
          RepaintBoundary(
            child: SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: effectiveMaxY,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: effectiveMaxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: context.colors.outlineVariant.withValues(
                        alpha: 0.4,
                      ),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              points[index].shortLabel,
                              style: context.textStyles.labelSmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => context.colors.inverseSurface,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isIncome = spot.barIndex == 0;
                          return LineTooltipItem(
                            spot.y.toStringAsFixed(0),
                            TextStyle(
                              color: isIncome
                                  ? semantic.income
                                  : semantic.expense,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    _buildLine(
                      points
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.income))
                          .toList(),
                      semantic.income,
                    ),
                    _buildLine(
                      points
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.expense))
                          .toList(),
                      semantic.expense,
                    ),
                  ],
                ),
                // Not an entrance animation (StaggeredEntrance already
                // handles that for this whole card) — fl_chart replays this
                // tween on *every* rebuild of LineChartData, not just when
                // the underlying points actually change, since a fresh
                // LineChartData/FlSpot list is built each time regardless of
                // whether the values differ. Left at fl_chart's ~600ms
                // default, that meant any dashboard rebuild (pull-to-refresh,
                // a provider elsewhere in the tree changing) re-triggered a
                // full repaint-every-frame animation on this chart, which is
                // what made the whole screen feel slow to render.
                duration: Duration.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.textStyles.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
