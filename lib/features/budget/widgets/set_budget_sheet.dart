import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/feedback/app_bottom_sheet.dart';
import '../../../core/widgets/inputs/currency_text_field.dart';
import '../../../services/snackbar_service.dart';
import '../providers/budget_controller.dart';

/// Shows the Set/Change Budget sheet. [currentAmount] pre-fills the field
/// (and shows "Remove budget") when one is already set. Returns nothing —
/// the caller doesn't need a result since [BudgetController] already
/// invalidates the dashboard on success.
Future<void> showSetBudgetSheet({
  required BuildContext context,
  required double? currentAmount,
  required String currencySymbol,
}) {
  return showAppBottomSheet<void>(
    context: context,
    title: currentAmount == null ? 'Set Monthly Budget' : 'Change Monthly Budget',
    builder: (context) => _SetBudgetForm(
      currentAmount: currentAmount,
      currencySymbol: currencySymbol,
    ),
  );
}

class _SetBudgetForm extends ConsumerStatefulWidget {
  final double? currentAmount;
  final String currencySymbol;

  const _SetBudgetForm({required this.currentAmount, required this.currencySymbol});

  @override
  ConsumerState<_SetBudgetForm> createState() => _SetBudgetFormState();
}

class _SetBudgetFormState extends ConsumerState<_SetBudgetForm> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(
    text: widget.currentAmount == null ? '' : widget.currentAmount!.toStringAsFixed(0),
  );

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;

    final result = await ref.read(budgetControllerProvider.notifier).setBudget(amount);
    if (!mounted) return;

    result.when(
      ok: (_) {
        ref.read(snackbarServiceProvider).showSuccess('Budget saved');
        Navigator.of(context).pop();
      },
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  Future<void> _remove() async {
    final result = await ref.read(budgetControllerProvider.notifier).clearBudget();
    if (!mounted) return;

    result.when(
      ok: (_) {
        ref.read(snackbarServiceProvider).showSuccess('Budget removed');
        Navigator.of(context).pop();
      },
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(budgetControllerProvider);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CurrencyTextField(
            label: 'Monthly Budget',
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
            label: 'Save',
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : _save,
          ),
          if (widget.currentAmount != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppOutlinedButton(
              label: 'Remove Budget',
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : _remove,
            ),
          ],
        ],
      ),
    );
  }
}
