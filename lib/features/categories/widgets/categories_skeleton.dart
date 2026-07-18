import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/feedback/shimmer_loading.dart';

/// Loading placeholder for the Categories list — a shimmering section
/// header followed by a few row-shaped blocks, repeated for the Expense
/// and Income groups.
class CategoriesSkeleton extends StatelessWidget {
  const CategoriesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          ShimmerListPlaceholder(itemCount: 4),
          SizedBox(height: AppSpacing.xl),
          ShimmerListPlaceholder(itemCount: 3),
        ],
      ),
    );
  }
}
