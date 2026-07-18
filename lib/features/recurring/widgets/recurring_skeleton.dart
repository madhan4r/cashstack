import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/feedback/shimmer_loading.dart';

/// Loading placeholder for the Recurring list.
class RecurringSkeleton extends StatelessWidget {
  const RecurringSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: ShimmerListPlaceholder(itemCount: 6),
    );
  }
}
