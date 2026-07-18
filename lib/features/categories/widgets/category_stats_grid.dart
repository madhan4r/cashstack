import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/cards/stat_card.dart';
import '../models/category.dart';

/// Number of Transactions / Total Amount / Last Used Date for the Category
/// Detail screen, laid out as a row of [StatCard]s.
class CategoryStatsGrid extends StatelessWidget {
  final Category category;
  final String currencySymbol;

  const CategoryStatsGrid({
    super.key,
    required this.category,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.7,
      children: [
        StatCard(
          label: 'Transactions',
          value: '${category.transactionCount}',
          icon: Icons.receipt_long_outlined,
        ),
        StatCard(
          label: 'Total Amount',
          value: '$currencySymbol${category.totalAmount.toAmount()}',
          icon: Icons.account_balance_wallet_outlined,
        ),
        StatCard(
          label: 'Last Used',
          value: category.lastUsedAt?.toRelativeLabel() ?? 'Never',
          icon: Icons.schedule_outlined,
        ),
        StatCard(
          label: 'Created',
          value: category.createdAt.toMediumDate(),
          icon: Icons.event_outlined,
        ),
      ],
    );
  }
}
