import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../../extensions/num_extensions.dart';

/// A single transaction row: category icon, title/subtitle, and a
/// signed, color-coded amount. Purely presentational — it takes primitive
/// values (no domain model), so it has zero coupling to how transactions
/// are fetched or stored.
class TransactionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double amount;
  final bool isExpense;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String currencySymbol;
  final VoidCallback? onTap;

  /// For non-income/expense movements (e.g. transfers between the user's
  /// own accounts): shows the amount without a +/- sign, in a neutral
  /// color instead of [isExpense]'s income/expense coloring.
  final bool isNeutral;

  const TransactionTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.amount,
    this.isExpense = true,
    this.icon = Icons.receipt_long_outlined,
    this.iconColor,
    this.iconBackgroundColor,
    this.currencySymbol = '\$',
    this.onTap,
    this.isNeutral = false,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final amountColor = isNeutral
        ? context.colors.onSurface
        : (isExpense ? semantic.expense : semantic.income);
    final resolvedIconColor = iconColor ?? context.colors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color:
                    iconBackgroundColor ??
                    resolvedIconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: resolvedIconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isNeutral
                  ? '$currencySymbol${amount.abs().toAmount()}'
                  : (isExpense
                        ? '-$currencySymbol${amount.abs().toAmount()}'
                        : '+$currencySymbol${amount.abs().toAmount()}'),
              style: context.textStyles.titleSmall?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
