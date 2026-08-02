import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/feedback/app_bottom_sheet.dart';
import '../../../core/widgets/inputs/currency_text_field.dart';

enum ContributeMode { add, withdraw }

/// Shows the Add/Withdraw money sheet for a savings goal and returns the
/// signed amount (positive to add, negative to withdraw), or `null` if
/// dismissed.
Future<double?> showContributeSheet({
  required BuildContext context,
  required String currencySymbol,
  required ContributeMode mode,
}) {
  return showAppBottomSheet<double>(
    context: context,
    title: mode == ContributeMode.add ? 'Add Money' : 'Withdraw Money',
    builder: (context) => _ContributeForm(currencySymbol: currencySymbol, mode: mode),
  );
}

class _ContributeForm extends StatefulWidget {
  final String currencySymbol;
  final ContributeMode mode;

  const _ContributeForm({required this.currencySymbol, required this.mode});

  @override
  State<_ContributeForm> createState() => _ContributeFormState();
}

class _ContributeFormState extends State<_ContributeForm> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    Navigator.of(context).pop(widget.mode == ContributeMode.add ? amount : -amount);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CurrencyTextField(
            label: 'Amount',
            symbol: widget.currencySymbol,
            controller: _amountController,
            autofocus: true,
            validator: (value) {
              final amount = double.tryParse((value ?? '').replaceAll(',', ''));
              if (amount == null || amount <= 0) return 'Enter an amount greater than 0';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: widget.mode == ContributeMode.add ? 'Add' : 'Withdraw',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
