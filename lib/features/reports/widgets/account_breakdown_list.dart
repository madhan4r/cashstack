import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/account_report_item.dart';

/// Spending grouped by account — income/expense per account for the
/// active period, sorted as the backend returns them (alphabetical).
class AccountBreakdownList extends StatelessWidget {
  final List<AccountReportItem> items;
  final String currencySymbol;
  final ValueChanged<AccountReportItem>? onTap;

  const AccountBreakdownList({
    super.key,
    required this.items,
    this.currencySymbol = '\$',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _AccountRow(
              item: items[i],
              currencySymbol: currencySymbol,
              onTap: onTap == null ? null : () => onTap!(items[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final AccountReportItem item;
  final String currencySymbol;
  final VoidCallback? onTap;

  const _AccountRow({required this.item, required this.currencySymbol, this.onTap});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: context.colors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.accountName,
                  style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.transactionCount} transactions',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+$currencySymbol${item.income.toAmount()}',
                style: context.textStyles.labelMedium?.copyWith(color: semantic.income),
              ),
              Text(
                '-$currencySymbol${item.expense.toAmount()}',
                style: context.textStyles.labelMedium?.copyWith(color: semantic.expense),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
