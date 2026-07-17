import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../../extensions/num_extensions.dart';
import 'app_card.dart';

/// Card showing progress toward a budget limit: label, spent/limit amounts,
/// and a progress bar that turns to the danger color once [spent] exceeds
/// [limit]. Purely presentational — the caller computes `spent`/`limit`.
class BudgetProgressCard extends StatelessWidget {
  final String label;
  final double spent;
  final double limit;
  final String currencySymbol;
  final Color? color;
  final VoidCallback? onTap;

  const BudgetProgressCard({
    super.key,
    required this.label,
    required this.spent,
    required this.limit,
    this.currencySymbol = '\$',
    this.color,
    this.onTap,
  });

  double get _progress => limit <= 0 ? 0 : (spent / limit).clamp(0, 1);

  bool get _isOverBudget => limit > 0 && spent > limit;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.primary;
    final barColor = _isOverBudget ? context.semanticColors.danger : tint;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: context.textStyles.titleSmall),
              Text(
                _progress.toPercentage(decimalDigits: 0),
                style: context.textStyles.labelMedium?.copyWith(
                  color: barColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _progress.toDouble(),
              minHeight: 8,
              backgroundColor: barColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$currencySymbol${spent.toAmount()} of $currencySymbol${limit.toAmount()}',
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
