import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import 'quick_action_card.dart';

class QuickActionItem {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });
}

/// Responsive grid of [QuickActionCard]s — 4 columns on phones (so all of
/// Add Expense/Add Income/Transfer/Reports sit on one row), more on wider
/// tablet layouts.
class QuickActionsGrid extends StatelessWidget {
  final List<QuickActionItem> items;

  const QuickActionsGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth) {
          > 900 => 6,
          > 600 => 5,
          _ => 4,
        };

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.85,
          children: items
              .map(
                (item) => QuickActionCard(
                  label: item.label,
                  icon: item.icon,
                  color: item.color,
                  onTap: item.onTap,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
