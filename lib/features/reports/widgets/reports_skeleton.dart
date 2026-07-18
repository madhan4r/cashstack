import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/feedback/shimmer_loading.dart';

/// Loading placeholder for the Reports Dashboard — a stack of card-shaped
/// shimmer blocks matching the summary grid, charts, and breakdown lists.
class ReportsSkeleton extends StatelessWidget {
  const ReportsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          ShimmerCardPlaceholder(height: 140),
          SizedBox(height: AppSpacing.md),
          ShimmerCardPlaceholder(height: 260),
          SizedBox(height: AppSpacing.md),
          ShimmerCardPlaceholder(height: 220),
          SizedBox(height: AppSpacing.md),
          ShimmerCardPlaceholder(height: 220),
        ],
      ),
    );
  }
}
