import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/confirmation_dialog.dart';

/// Confirms permanently deleting a recurring transaction — its schedule
/// and history log are removed, but transactions it already generated stay
/// in the ledger.
Future<bool?> showDeleteRecurringConfirmation({
  required BuildContext context,
  required String name,
}) {
  return showAppConfirmationDialog(
    context: context,
    title: 'Delete recurring transaction?',
    message:
        '"$name" will stop generating new transactions. Transactions already '
        'created from it are kept. This can\'t be undone.',
    confirmLabel: 'Delete',
    isDestructive: true,
  );
}
