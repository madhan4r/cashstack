import 'package:flutter/material.dart';

/// Themed floating action button. Use [AppFab.extended] for a labeled FAB
/// (e.g. "Add transaction"); the default constructor is icon-only.
class AppFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final String? tooltip;

  const AppFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.tooltip,
  }) : label = null;

  const AppFab.extended({
    super.key,
    required this.onPressed,
    required String this.label,
    this.icon = Icons.add_rounded,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
