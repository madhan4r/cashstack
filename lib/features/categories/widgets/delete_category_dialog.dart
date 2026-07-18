import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/confirmation_dialog.dart';

/// Confirms permanently deleting a category. Only offered when the
/// category has zero transactions — see [CategoryFormState.canDelete].
Future<bool?> showDeleteCategoryConfirmation({
  required BuildContext context,
  required String categoryName,
}) {
  return showAppConfirmationDialog(
    context: context,
    title: 'Delete category?',
    message: '"$categoryName" will be permanently removed. This can\'t be undone.',
    confirmLabel: 'Delete',
    isDestructive: true,
  );
}

/// Confirms archiving/unarchiving. Archiving is the only option once a
/// category has transactions against it — fully reversible, so a lighter
/// confirmation than delete.
Future<bool?> showArchiveCategoryConfirmation({
  required BuildContext context,
  required String categoryName,
  required bool isCurrentlyArchived,
  bool hasTransactions = false,
}) {
  final action = isCurrentlyArchived ? 'Unarchive' : 'Archive';
  final message = isCurrentlyArchived
      ? '"$categoryName" will reappear in your default category list.'
      : hasTransactions
          ? '"$categoryName" has existing transactions, so it can\'t be deleted — '
                'archiving hides it from pickers and the default list instead.'
          : '"$categoryName" will be hidden from your default category list. '
                'You can unarchive it anytime.';

  return showAppConfirmationDialog(
    context: context,
    title: '$action category?',
    message: message,
    confirmLabel: action,
  );
}
