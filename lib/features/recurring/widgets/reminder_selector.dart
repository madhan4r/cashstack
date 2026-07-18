import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/cards/category_chip.dart';
import '../models/reminder_option.dart';

/// Wrap of selectable [ReminderOption] chips — No reminder through 7 days
/// before.
class ReminderSelector extends StatelessWidget {
  final ReminderOption value;
  final ValueChanged<ReminderOption> onChanged;

  const ReminderSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: ReminderOption.values
          .map(
            (r) => CategoryChip(
              label: r.label,
              icon: r == ReminderOption.none ? Icons.notifications_off_outlined : Icons.notifications_outlined,
              selected: r == value,
              onTap: () => onChanged(r),
            ),
          )
          .toList(),
    );
  }
}
