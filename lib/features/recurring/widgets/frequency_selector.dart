import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/cards/category_chip.dart';
import '../models/recurrence_frequency.dart';

/// Wrap of selectable [RecurrenceFrequency] chips — Daily through Custom.
class FrequencySelector extends StatelessWidget {
  final RecurrenceFrequency value;
  final ValueChanged<RecurrenceFrequency> onChanged;

  const FrequencySelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: RecurrenceFrequency.values
          .map(
            (f) => CategoryChip(
              label: f.label,
              selected: f == value,
              onTap: () => onChanged(f),
            ),
          )
          .toList(),
    );
  }
}
