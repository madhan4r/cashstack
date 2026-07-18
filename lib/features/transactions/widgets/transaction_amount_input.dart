import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/inputs/currency_text_field.dart' show ThousandsSeparatorFormatter;

/// The form's hero field: a large, centered, currency-formatted amount
/// input with a numeric-only keypad. Deliberately not styled like a
/// standard boxed text field — this is the single most important value on
/// the screen, so it gets the visual weight.
class TransactionAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String currencySymbol;
  final String? errorText;
  final ValueChanged<double> onChanged;
  final bool autofocus;

  const TransactionAmountInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.currencySymbol = '\$',
    this.errorText,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final errorColor = context.colors.error;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                currencySymbol,
                style: context.textStyles.headlineMedium?.copyWith(
                  color: hasError
                      ? errorColor
                      : context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IntrinsicWidth(
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [ThousandsSeparatorFormatter()],
                style: context.textStyles.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasError ? errorColor : null,
                ),
                decoration: const InputDecoration(
                  hintText: '0',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(value.replaceAll(',', '')) ?? 0;
                  onChanged(parsed);
                },
              ),
            ),
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: context.textStyles.bodySmall?.copyWith(color: errorColor),
          ),
        ],
      ],
    );
  }
}
