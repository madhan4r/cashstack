import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../shared/models/transaction_kind.dart';
import '../models/account_ref.dart';
import '../models/category_ref.dart';
import '../models/transaction.dart';

/// A detailed transaction row for the Transactions list: category icon,
/// category name, notes, account name, date, payment method, and a
/// color-coded signed amount. Purely presentational — category/account
/// names are passed in already resolved (see `ReferenceData`) rather than
/// looked up here.
class TransactionListTile extends StatelessWidget {
  final Transaction transaction;
  final CategoryRef? category;
  final AccountRef? account;
  final VoidCallback? onTap;

  const TransactionListTile({
    super.key,
    required this.transaction,
    this.category,
    this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final isTransfer = transaction.kind == TransactionKind.transfer;
    final isExpense = transaction.kind == TransactionKind.expense;

    final amountColor = isTransfer
        ? context.colors.onSurface
        : (isExpense ? semantic.expense : semantic.income);
    final tint = isTransfer
        ? context.colors.onSurfaceVariant
        : colorFromHex(category?.color, fallback: context.colors.primary);
    final icon = isTransfer
        ? Icons.swap_horiz_rounded
        : categoryIconFor(category?.icon);

    final title = isTransfer ? 'Transfer' : (category?.name ?? 'Uncategorized');
    final amountText = isTransfer
        ? transaction.amount.toAmount()
        : transaction.amount.toSignedAmount();

    final metaParts = [
      if (account != null) account!.name,
      transaction.transactionDate.toRelativeLabel(),
      if (transaction.paymentMethod != null) transaction.paymentMethod!.label,
    ];

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.textStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      amountText,
                      style: context.textStyles.titleSmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (transaction.notes != null && transaction.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.notes!.trim(),
                    style: context.textStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  metaParts.join(' • '),
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
