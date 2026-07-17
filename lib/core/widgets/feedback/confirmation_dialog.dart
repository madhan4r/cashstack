import 'package:flutter/material.dart';

import '../buttons/app_primary_button.dart';
import '../buttons/app_text_button.dart';

/// Themed confirm/cancel dialog. Call [showAppConfirmationDialog] rather
/// than constructing this directly — it returns `true`/`false`/`null`
/// (dismissed) for straightforward `if (confirmed == true)` handling.
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        AppTextButton(
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppPrimaryButton(
          label: confirmLabel,
          fullWidth: false,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      backgroundColor: isDestructive
          ? colorScheme.errorContainer.withValues(alpha: 0.15)
          : null,
    );
  }
}

/// Shows a [ConfirmationDialog] and returns the user's choice: `true`
/// (confirmed), `false` (cancelled), or `null` (dismissed by tapping
/// outside / back button).
Future<bool?> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ConfirmationDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
    ),
  );
}
