import 'package:flutter/material.dart';

import '../models/date_range_preset.dart';

/// A single selectable date-range preset pill. [DateFilterRow] lays a row
/// of these out for Today/This Week/This Month/Last Month/This Year, plus
/// a trailing custom-range trigger.
class DateFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  const DateFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      avatar: icon == null ? null : Icon(icon, size: 16),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

/// Horizontally-scrollable row of every [DateRangePreset] plus a "Custom"
/// trigger. Selecting Custom invokes [onCustomTap] (typically opening a
/// date-range picker) rather than applying a preset directly.
class DateFilterRow extends StatelessWidget {
  final DateRangePreset selected;
  final ValueChanged<DateRangePreset> onSelected;
  final VoidCallback onCustomTap;

  const DateFilterRow({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    final presets = DateRangePreset.values.where((p) => p != DateRangePreset.custom);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final preset in presets) ...[
            DateFilterChip(
              label: preset.label,
              selected: selected == preset,
              onTap: () => onSelected(preset),
            ),
            const SizedBox(width: 8),
          ],
          DateFilterChip(
            label: selected == DateRangePreset.custom ? 'Custom' : 'Custom range',
            icon: Icons.date_range_outlined,
            selected: selected == DateRangePreset.custom,
            onTap: onCustomTap,
          ),
        ],
      ),
    );
  }
}
