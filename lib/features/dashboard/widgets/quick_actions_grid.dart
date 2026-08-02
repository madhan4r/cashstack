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

        // A GridView forces every cell to a fixed height (via
        // childAspectRatio), which overflows as soon as the label wraps to
        // a taller line than that ratio assumed — e.g. a larger system
        // font-scale setting. A Wrap of fixed-width cards lets each one
        // size to its own content height instead.
        final cellWidth =
            (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: items
              .map(
                (item) => SizedBox(
                  width: cellWidth,
                  child: QuickActionCard(
                    label: item.label,
                    icon: item.icon,
                    color: item.color,
                    onTap: item.onTap,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
