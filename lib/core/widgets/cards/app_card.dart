import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';

/// Base surface used by every card in the design system (list tiles,
/// stats, account cards, …) so padding/radius/tap behavior are consistent.
/// Prefer the specific card widgets (e.g. [StatCard]) for common patterns;
/// use this directly for one-off card layouts.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.backgroundColor,
    this.borderRadius = AppRadius.radiusLg,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: backgroundColor ?? theme.colorScheme.surfaceContainer,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(borderRadius: borderRadius, border: border),
          child: child,
        ),
      ),
    );
  }
}
