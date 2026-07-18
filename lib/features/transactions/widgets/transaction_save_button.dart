import 'package:flutter/material.dart';

import '../../../core/widgets/buttons/app_primary_button.dart';

/// The form's primary action — labeled "Save Transaction" or "Update
/// Transaction" depending on mode, with the standard loading/disabled
/// state while submitting.
class TransactionSaveButton extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback? onPressed;

  const TransactionSaveButton({
    super.key,
    required this.isEditMode,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      label: isEditMode ? 'Update Transaction' : 'Save Transaction',
      isLoading: isLoading,
      onPressed: onPressed,
    );
  }
}
