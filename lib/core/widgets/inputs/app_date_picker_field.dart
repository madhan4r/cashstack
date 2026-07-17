import 'package:flutter/material.dart';

import '../../extensions/date_extensions.dart';

/// A tappable, read-only field that opens a themed [showDatePicker] and
/// displays the chosen date. Use [showAppDatePicker] directly if you need
/// to trigger the picker from something other than a field (e.g. a filter
/// chip).
class AppDatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;

  const AppDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      enabled: enabled,
      controller: TextEditingController(
        text: value == null ? '' : value!.toMediumDate(),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      onTap: () async {
        final picked = await showAppDatePicker(
          context: context,
          initialDate: value,
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

/// Themed wrapper around [showDatePicker] so every date picker in the app
/// looks the same without every call site re-specifying builder theming.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: firstDate ?? DateTime(now.year - 10),
    lastDate: lastDate ?? DateTime(now.year + 10),
  );
}
