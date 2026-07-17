import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'app_text_field.dart';

/// Numeric input for money amounts: shows a currency [symbol] prefix and
/// live-formats thousands separators as the user types (`12000` →
/// `12,000`). [onAmountChanged] receives the parsed numeric value.
class CurrencyTextField extends StatelessWidget {
  final String label;
  final String symbol;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(double amount)? onAmountChanged;
  final bool autofocus;
  final bool enabled;

  const CurrencyTextField({
    super.key,
    this.label = 'Amount',
    this.symbol = '\$',
    this.controller,
    this.validator,
    this.onAmountChanged,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      validator: validator,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [_ThousandsSeparatorFormatter()],
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Center(
          widthFactor: 1,
          child: Text(
            symbol,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      onChanged: (value) {
        final parsed = double.tryParse(value.replaceAll(',', '')) ?? 0;
        onAmountChanged?.call(parsed);
      },
    );
  }
}

/// Reformats the raw digits as `12,345.67` on every keystroke while keeping
/// the cursor at the end (simple, predictable behavior for a numeric-only
/// field — full caret-position preservation isn't needed here since amounts
/// are short and typed left-to-right).
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  static final _formatter = NumberFormat.decimalPattern();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsAndDot = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    if (digitsAndDot.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final parts = digitsAndDot.split('.');
    final wholePart = parts.first.isEmpty ? '0' : parts.first;
    final wholeNumber = int.tryParse(wholePart);
    if (wholeNumber == null) {
      return oldValue;
    }

    final formattedWhole = _formatter.format(wholeNumber);
    final hasDecimal = parts.length > 1;
    final decimalPart = hasDecimal ? parts[1] : '';
    final formatted = hasDecimal
        ? '$formattedWhole.$decimalPart'
        : formattedWhole;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
