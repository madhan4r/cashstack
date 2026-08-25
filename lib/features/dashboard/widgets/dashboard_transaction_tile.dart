import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/cards/transaction_tile.dart';
import '../../../shared/models/transaction_kind.dart';
import '../../auth/providers/auth_controller.dart';
import '../models/dashboard_transaction.dart';

/// Adapts a [DashboardTransaction] onto the design system's
/// [TransactionTile] — maps category icon/color strings, builds the
/// notes/date subtitle, and picks the right income/expense/neutral
/// styling for the transaction's [TransactionKind]. A `ConsumerWidget`
/// purely to check whether this transaction was added by the signed-in
/// user or a household member, same as `TransactionListTile`.
class DashboardTransactionTile extends ConsumerWidget {
  final DashboardTransaction transaction;
  final String currencySymbol;
  final VoidCallback? onTap;

  const DashboardTransactionTile({
    super.key,
    required this.transaction,
    this.currencySymbol = '\$',
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUserId = ref.watch(authControllerProvider).user?.id;
    final isSharedItem =
        transaction.ownerId.isNotEmpty && transaction.ownerId != myUserId;
    final isTransfer = transaction.kind == TransactionKind.transfer;
    final title = transaction.categoryName ??
        (isTransfer ? 'Transfer' : 'Uncategorized');
    final subtitleParts = [
      if (transaction.notes != null && transaction.notes!.trim().isNotEmpty)
        transaction.notes!.trim(),
      transaction.transactionDate.toRelativeLabel(),
      if (isSharedItem && transaction.ownerName != null)
        'via ${transaction.ownerName}',
    ];

    return TransactionTile(
      title: title,
      subtitle: subtitleParts.join(' • '),
      amount: transaction.amount,
      currencySymbol: currencySymbol,
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
