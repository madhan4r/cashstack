import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';

/// Selectable pill for a category (or any tag-like filter) — an icon,
/// label, and a distinguishing [color], with a filled state when
/// [selected].
class CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.primary;
    final background = selected ? tint : tint.withValues(alpha: 0.12);
    final foreground = selected ? _onColor(tint) : tint;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: context.textStyles.labelMedium?.copyWith(
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Picks black/white text for readability against an arbitrary [background].
  Color _onColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
