import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/cards/transaction_tile.dart';
import '../../../shared/models/transaction_kind.dart';
import '../models/dashboard_transaction.dart';

/// Adapts a [DashboardTransaction] onto the design system's
/// [TransactionTile] — maps category icon/color strings, builds the
/// notes/date subtitle, and picks the right income/expense/neutral
/// styling for the transaction's [TransactionKind].
class DashboardTransactionTile extends StatelessWidget {
  final DashboardTransaction transaction;
  final VoidCallback? onTap;

  const DashboardTransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTransfer = transaction.kind == TransactionKind.transfer;
    final title = transaction.categoryName ??
        (isTransfer ? 'Transfer' : 'Uncategorized');
    final subtitleParts = [
      if (transaction.notes != null && transaction.notes!.trim().isNotEmpty)
        transaction.notes!.trim(),
      transaction.transactionDate.toRelativeLabel(),
    ];

    return TransactionTile(
      title: title,
      subtitle: subtitleParts.join(' • '),
      amount: transaction.amount,
      isExpense: transaction.kind == TransactionKind.expense,
      isNeutral: isTransfer,
      icon: isTransfer
          ? Icons.swap_horiz_rounded
          : categoryIconFor(transaction.categoryIcon),
      iconColor: isTransfer
          ? context.colors.onSurfaceVariant
          : colorFromHex(transaction.categoryColor, fallback: context.colors.primary),
      onTap: onTap,
    );
  }
}
