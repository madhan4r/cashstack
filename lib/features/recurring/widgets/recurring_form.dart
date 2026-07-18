import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/cards/category_chip.dart';
import '../../../core/widgets/inputs/app_date_picker_field.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/currency_text_field.dart';
import '../../../shared/models/transaction_kind.dart';
import '../models/recurrence_frequency.dart';
import '../models/reminder_option.dart';
import 'frequency_selector.dart';
import 'reminder_selector.dart';

/// The Add/Edit Recurring Transaction form fields. Purely presentational —
/// the screen owns the [TextEditingController]s and
/// [RecurringFormController] state, and wires them through here.
class RecurringFormBody extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final TextEditingController customIntervalController;

  final TransactionKind type;
  final ValueChanged<TransactionKind> onTypeChanged;

  final String categoryLabel;
  final IconData categoryIcon;
  final VoidCallback onTapCategory;

  final String accountLabel;
  final VoidCallback onTapAccount;

  final RecurrenceFrequency frequency;
  final ValueChanged<RecurrenceFrequency> onFrequencyChanged;

  final DateTime startDate;
  final ValueChanged<DateTime> onStartDateChanged;

  final DateTime? endDate;
  final ValueChanged<DateTime?> onEndDateChanged;

  final ReminderOption reminder;
  final ValueChanged<ReminderOption> onReminderChanged;

  final bool autoGenerate;
  final ValueChanged<bool> onAutoGenerateChanged;

  final bool showValidationErrors;
  final Map<String, String> fieldErrors;
  final String currencySymbol;

  const RecurringFormBody({
    super.key,
    required this.nameController,
    required this.amountController,
    required this.notesController,
    required this.customIntervalController,
    required this.type,
    required this.onTypeChanged,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.onTapCategory,
    required this.accountLabel,
    required this.onTapAccount,
    required this.frequency,
    required this.onFrequencyChanged,
    required this.startDate,
    required this.onStartDateChanged,
    required this.endDate,
    required this.onEndDateChanged,
    required this.reminder,
    required this.onReminderChanged,
    required this.autoGenerate,
    required this.onAutoGenerateChanged,
    this.showValidationErrors = false,
    this.fieldErrors = const {},
    this.currencySymbol = '\$',
  });

  String? _errorFor(String field) => showValidationErrors ? fieldErrors[field] : null;

  Widget _errorText(BuildContext context, String field) {
    final error = _errorFor(field);
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        error,
        style: context.textStyles.bodySmall?.copyWith(color: context.colors.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(label: 'Transaction Name', hint: 'e.g. Netflix Subscription', controller: nameController),
        _errorText(context, 'name'),
        const SizedBox(height: AppSpacing.lg),
        Text('Transaction Type', style: context.textStyles.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            CategoryChip(
              label: 'Expense',
              color: semantic.expense,
              selected: type == TransactionKind.expense,
              onTap: () => onTypeChanged(TransactionKind.expense),
            ),
            const SizedBox(width: AppSpacing.sm),
            CategoryChip(
              label: 'Income',
              color: semantic.income,
              selected: type == TransactionKind.income,
              onTap: () => onTypeChanged(TransactionKind.income),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        CurrencyTextField(label: 'Amount', symbol: currencySymbol, controller: amountController),
        _errorText(context, 'amount'),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Category',
          controller: TextEditingController(text: categoryLabel),
          readOnly: true,
          prefixIcon: Icon(categoryIcon),
          suffixIcon: const Icon(Icons.chevron_right_rounded),
          onTap: onTapCategory,
        ),
        _errorText(context, 'category'),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Account',
          controller: TextEditingController(text: accountLabel),
          readOnly: true,
          prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          suffixIcon: const Icon(Icons.chevron_right_rounded),
          onTap: onTapAccount,
        ),
        _errorText(context, 'account'),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(label: 'Notes (optional)', controller: notesController, maxLines: 2, maxLength: 250),
        const SizedBox(height: AppSpacing.lg),
        Text('Frequency', style: context.textStyles.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        FrequencySelector(value: frequency, onChanged: onFrequencyChanged),
        if (frequency == RecurrenceFrequency.custom) ...[
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Repeat every (days)',
            controller: customIntervalController,
            keyboardType: TextInputType.number,
          ),
          _errorText(context, 'customIntervalDays'),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AppDatePickerField(
                label: 'Start Date',
                value: startDate,
                lastDate: endDate,
                onChanged: onStartDateChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppDatePickerField(
                label: 'End Date (optional)',
                value: endDate,
                firstDate: startDate,
                onChanged: onEndDateChanged,
              ),
            ),
          ],
        ),
        _errorText(context, 'endDate'),
        const SizedBox(height: AppSpacing.lg),
        Text('Reminder', style: context.textStyles.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        ReminderSelector(value: reminder, onChanged: onReminderChanged),
        const SizedBox(height: AppSpacing.lg),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto Generate'),
          subtitle: const Text('Automatically create the transaction when it\'s due'),
          value: autoGenerate,
          onChanged: onAutoGenerateChanged,
        ),
      ],
    );
  }
}
