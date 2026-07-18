import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/confirmation_dialog.dart';

/// Confirms permanently deleting an account. Thin, account-specific wrapper
/// around the shared [showAppConfirmationDialog] so callers get consistent
/// copy without re-typing it at every call site.
Future<bool?> showDeleteAccountConfirmation({
  required BuildContext context,
  required String accountName,
}) {
  return showAppConfirmationDialog(
    context: context,
    title: 'Delete account?',
    message:
        '"$accountName" and its transaction history will no longer appear '
        'anywhere in the app. This can\'t be undone.',
    confirmLabel: 'Delete',
    isDestructive: true,
  );
}

/// Confirms archiving/unarchiving — much lower-stakes than delete (fully
/// reversible), so a lighter confirmation copy.
Future<bool?> showArchiveAccountConfirmation({
  required BuildContext context,
  required String accountName,
  required bool isCurrentlyArchived,
}) {
  final action = isCurrentlyArchived ? 'Unarchive' : 'Archive';
  return showAppConfirmationDialog(
    context: context,
    title: '$action account?',
    message: isCurrentlyArchived
        ? '"$accountName" will reappear in your default accounts list.'
        : '"$accountName" will be hidden from your default accounts list. '
              'You can unarchive it anytime.',
    confirmLabel: action,
  );
}
