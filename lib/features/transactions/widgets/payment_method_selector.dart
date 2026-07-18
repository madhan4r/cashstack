import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/cards/category_chip.dart';
import '../models/payment_method.dart';

/// Optional payment method, as a row of selectable chips. Selecting the
/// already-active chip clears it (payment method isn't required).
class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod? value;
  final ValueChanged<PaymentMethod?> onChanged;

  const PaymentMethodSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: PaymentMethod.values.map((method) {
        final isSelected = method == value;
        return CategoryChip(
          label: method.label,
          icon: method.icon,
          selected: isSelected,
          onTap: () => onChanged(isSelected ? null : method),
        );
      }).toList(),
    );
  }
}
