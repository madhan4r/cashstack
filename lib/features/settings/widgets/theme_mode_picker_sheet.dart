import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/app_bottom_sheet.dart';

/// Shows the Appearance picker and returns the selected [ThemeMode], or
/// `null` if dismissed without a change.
Future<ThemeMode?> showThemeModePickerSheet({
  required BuildContext context,
  required ThemeMode selected,
}) {
  return showAppBottomSheet<ThemeMode>(
    context: context,
    title: 'Appearance',
    builder: (context) => _ThemeModeList(selected: selected),
  );
}

const _options = [
  (mode: ThemeMode.system, label: 'System default', icon: Icons.brightness_auto_rounded),
  (mode: ThemeMode.light, label: 'Light', icon: Icons.light_mode_outlined),
  (mode: ThemeMode.dark, label: 'Dark', icon: Icons.dark_mode_outlined),
];

class _ThemeModeList extends StatelessWidget {
  final ThemeMode selected;

  const _ThemeModeList({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in _options)
          ListTile(
            leading: Icon(option.icon),
            title: Text(option.label),
            trailing: option.mode == selected
                ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () => Navigator.of(context).pop(option.mode),
          ),
      ],
    );
  }
}
