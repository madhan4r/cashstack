import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import 'app_card.dart';

/// Small KPI-style card: a label, a large value, an accent icon, and an
/// optional trend indicator (e.g. "+4.2% vs last month"). Purely
/// presentational — pass already-formatted [value]/[trendLabel] strings.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? trendLabel;
  final bool isPositiveTrend;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.trendLabel,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.primary;
    final trendColor = isPositiveTrend
        ? context.semanticColors.success
        : context.semanticColors.danger;

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
              if (icon != null)
                Icon(icon, size: 18, color: tint),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: context.textStyles.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (trendLabel != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositiveTrend
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 14,
                  color: trendColor,
                ),
                const SizedBox(width: 4),
                Text(
                  trendLabel!,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: trendColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
