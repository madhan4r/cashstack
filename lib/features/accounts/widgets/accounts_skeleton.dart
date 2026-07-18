import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/feedback/shimmer_loading.dart';

/// Loading placeholder for the Accounts list — a column of card-shaped
/// shimmer blocks matching [AccountListItem]'s footprint.
class AccountsSkeleton extends StatelessWidget {
  final int itemCount;

  const AccountsSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: ShimmerCardPlaceholder(height: 110),
        ),
      ),
    );
  }
}
