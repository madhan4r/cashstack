import 'package:flutter/material.dart';

/// A tappable, read-only field that opens a themed [showTimePicker] and
/// displays the chosen time. Sibling to [AppDatePickerField] — use
/// [showAppTimePicker] directly if you need to trigger the picker from
/// something other than a field.
class AppTimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  final bool enabled;

  const AppTimePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      enabled: enabled,
      controller: TextEditingController(
        text: value == null ? '' : value!.format(context),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.access_time_rounded),
      ),
      onTap: () async {
        final picked = await showAppTimePicker(
          context: context,
          initialTime: value,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

/// Themed wrapper around [showTimePicker] so every time picker in the app
/// looks the same without every call site re-specifying builder theming.
Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime ?? TimeOfDay.now(),
  );
}
