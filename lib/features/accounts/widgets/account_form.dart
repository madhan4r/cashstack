import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/inputs/app_dropdown.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/currency_text_field.dart';
import '../models/account_type.dart';
import '../../../core/utils/currency.dart';
import 'account_type_chip.dart';

/// The Add/Edit Account form fields: name, type, currency, opening
/// balance, and an optional description. Purely presentational — the
/// screen owns the [TextEditingController]s and [AccountFormController]
/// state, and wires them through here.
class AccountFormBody extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController openingBalanceController;
  final TextEditingController descriptionController;

  final AccountType type;
  final ValueChanged<AccountType> onTypeChanged;

  final String currency;
  final ValueChanged<String> onCurrencyChanged;

  final bool showValidationErrors;
  final Map<String, String> fieldErrors;

  const AccountFormBody({
    super.key,
    required this.nameController,
    required this.openingBalanceController,
    required this.descriptionController,
    required this.type,
    required this.onTypeChanged,
    required this.currency,
    required this.onCurrencyChanged,
    this.showValidationErrors = false,
    this.fieldErrors = const {},
  });

  String? _errorFor(String field) =>
      showValidationErrors ? fieldErrors[field] : null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Account Name',
          hint: 'e.g. HDFC Savings',
          controller: nameController,
          textInputAction: TextInputAction.next,
        ),
        if (_errorFor('name') != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _errorFor('name')!,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Account Type', style: context.textStyles.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: AccountType.values
              .map(
                (t) => AccountTypeChip(
                  type: t,
                  selected: t == type,
                  onTap: () => onTypeChanged(t),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppDropdown<String>(
          label: 'Currency',
          value: supportedCurrencies.any((c) => c.code == currency) ? currency : null,
          items: supportedCurrencies.map((c) => c.code).toList(),
          labelBuilder: (code) {
            final currencyOption = supportedCurrencies.firstWhere((c) => c.code == code);
            return '${currencyOption.code} — ${currencyOption.name}';
          },
          onChanged: (value) {
            if (value != null) onCurrencyChanged(value);
          },
        ),
        if (_errorFor('currency') != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _errorFor('currency')!,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        CurrencyTextField(
          label: 'Opening Balance',
          symbol: currencySymbolFor(currency),
          controller: openingBalanceController,
        ),
        if (_errorFor('openingBalance') != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _errorFor('openingBalance')!,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Description (optional)',
          hint: 'Add a note about this account',
          controller: descriptionController,
          maxLines: 3,
          maxLength: 500,
        ),
      ],
    );
  }
}
