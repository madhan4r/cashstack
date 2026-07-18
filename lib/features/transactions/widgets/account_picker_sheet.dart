import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/app_bottom_sheet.dart';
import '../models/account_ref.dart';
import 'account_selector.dart';

/// Shows the account picker and returns the selected account id, or
/// `null` if dismissed without a selection.
Future<String?> showAccountPickerSheet({
  required BuildContext context,
  required List<AccountRef> accounts,
  required String title,
  String? selectedAccountId,
  String? excludeAccountId,
}) {
  return showAppBottomSheet<String>(
    context: context,
    title: title,
    builder: (context) => AccountSelector(
      accounts: accounts,
      selectedAccountId: selectedAccountId,
      excludeAccountId: excludeAccountId,
      onSelected: (id) => Navigator.of(context).pop(id),
    ),
  );
}
