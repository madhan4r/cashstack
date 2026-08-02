import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/feedback/app_bottom_sheet.dart';

/// Shows the preferred-currency picker and returns the selected currency
/// code, or `null` if dismissed without a change.
Future<String?> showCurrencyPickerSheet({
  required BuildContext context,
  required String selectedCode,
}) {
  return showAppBottomSheet<String>(
    context: context,
    title: 'Preferred Currency',
    builder: (context) => _CurrencyList(selectedCode: selectedCode),
  );
}

class _CurrencyList extends StatelessWidget {
  final String selectedCode;

  const _CurrencyList({required this.selectedCode});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: supportedCurrencies.length,
      itemBuilder: (context, index) {
        final currency = supportedCurrencies[index];
        final isSelected = currency.code == selectedCode;
        return ListTile(
          leading: SizedBox(
            width: 32,
            child: Text(
              currency.symbol,
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium,
            ),
          ),
          title: Text(currency.name),
          subtitle: Text(currency.code),
          trailing: isSelected
              ? Icon(Icons.check_circle_rounded, color: context.colors.primary)
              : null,
          onTap: () => Navigator.of(context).pop(currency.code),
        );
      },
    );
  }
}
