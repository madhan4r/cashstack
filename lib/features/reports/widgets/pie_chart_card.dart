import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/category_breakdown_item.dart';

const _palette = [
  Color(0xFF16A34A),
  Color(0xFFF97316),
  Color(0xFF8B5CF6),
  Color(0xFF06B6D4),
  Color(0xFFEC4899),
  Color(0xFFEAB308),
  Color(0xFF3B82F6),
  Color(0xFFEF4444),
];

/// Category Spending doughnut chart with a legend listing each category's
/// share. Categories don't carry their own accent color in the report
/// response (only `categoryId`/`categoryName`), so slices cycle through a
/// fixed palette by position — consistent and legible without needing a
/// join against the categories cache just for a chart color.
class PieChartCard extends StatefulWidget {
  final List<CategoryBreakdownItem> items;
  final String currencySymbol;
  final ValueChanged<CategoryBreakdownItem>? onTapSegment;

  const PieChartCard({
    super.key,
    required this.items,
    this.currencySymbol = '\$',
    this.onTapSegment,
  });

  @override
  State<PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<PieChartCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Center(
            child: Text(
              'No category spending in this period',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 52,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (!event.isInterestedForInteractions ||
                        response?.touchedSection == null) {
                      setState(() => _touchedIndex = null);
                      return;
                    }
                    final index = response!.touchedSection!.touchedSectionIndex;
                    setState(() => _touchedIndex = index);
                    if (event is FlTapUpEvent &&
                        index >= 0 &&
                        index < widget.items.length) {
                      widget.onTapSegment?.call(widget.items[index]);
                    }
                  },
                ),
                sections: [
                  for (var i = 0; i < widget.items.length; i++)
                    _section(context, i, widget.items[i]),
                ],
              ),
              duration: const Duration(milliseconds: 500),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < widget.items.length; i++)
                _LegendEntry(
                  color: _colorFor(i),
                  name: widget.items[i].categoryName,
                  percentage: widget.items[i].percentage,
                ),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(BuildContext context, int index, CategoryBreakdownItem item) {
    final isTouched = index == _touchedIndex;
    final color = _colorFor(index);

    return PieChartSectionData(
      color: color,
      value: item.amount <= 0 ? 0.001 : item.amount,
      title: '${item.percentage.toStringAsFixed(0)}%',
      radius: isTouched ? 58 : 50,
      titleStyle: context.textStyles.labelSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Color _colorFor(int index) => _palette[index % _palette.length];
}

class _LegendEntry extends StatelessWidget {
  final Color color;
  final String name;
  final double percentage;

  const _LegendEntry({required this.color, required this.name, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$name (${percentage.toStringAsFixed(0)}%)',
          style: context.textStyles.labelSmall,
        ),
      ],
    );
  }
}
