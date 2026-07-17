import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/feedback/shimmer_loading.dart';

/// Skeleton placeholder shown while the first page of transactions loads.
class TransactionsSkeleton extends StatelessWidget {
  const TransactionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: ShimmerListPlaceholder(itemCount: 8),
    );
  }
}
