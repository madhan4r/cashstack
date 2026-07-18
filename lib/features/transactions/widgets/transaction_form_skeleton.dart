import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/feedback/shimmer_loading.dart';

/// Skeleton shown while fetching the existing transaction in Edit mode.
class TransactionFormSkeleton extends StatelessWidget {
  const TransactionFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: ShimmerBox(width: 140, height: 44)),
            SizedBox(height: AppSpacing.xl),
            ShimmerBox(height: 44, borderRadius: AppRadius.radiusPill),
            SizedBox(height: AppSpacing.lg),
            ShimmerBox(height: 56),
            SizedBox(height: AppSpacing.md),
            ShimmerBox(height: 56),
            SizedBox(height: AppSpacing.lg),
            ShimmerBox(height: 56),
            SizedBox(height: AppSpacing.md),
            ShimmerBox(height: 90),
          ],
        ),
      ),
    );
  }
}
