import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/spending_insight.dart';

/// Surfaces categories spending significantly above their trailing-months
/// average this month (see the backend's `buildSpendingInsights`). Renders
/// nothing when there's nothing worth flagging — most months, for most
/// users, this is the common case.
class SpendingInsightsCard extends StatelessWidget {
  final List<SpendingInsight> insights;

  const SpendingInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    final tint = context.semanticColors.warning;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < insights.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights_rounded, size: 18, color: tint),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    insights[i].message,
                    style: context.textStyles.bodyMedium,
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
