import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/feedback/shimmer_loading.dart';

/// Skeleton placeholder mirroring the real dashboard layout, shown while
/// [dashboardControllerProvider] is loading for the first time.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 100, height: 12),
                  SizedBox(height: AppSpacing.xs),
                  ShimmerBox(width: 160, height: 20),
                ],
              ),
            ),
            const ShimmerBox(
              width: 44,
              height: 44,
              borderRadius: AppRadius.radiusPill,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const ShimmerCardPlaceholder(height: 190),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : AppSpacing.sm),
                child: const ShimmerCardPlaceholder(height: 84),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const ShimmerBox(width: 140, height: 18),
        const SizedBox(height: AppSpacing.md),
        const ShimmerCardPlaceholder(height: 160),
        const SizedBox(height: AppSpacing.lg),
        const ShimmerBox(width: 160, height: 18),
        const SizedBox(height: AppSpacing.md),
        const ShimmerListPlaceholder(itemCount: 4),
      ],
    );
  }
}
