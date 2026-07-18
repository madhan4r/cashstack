import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/num_extensions.dart';

/// Large, prominent balance display — the Account Details header's hero
/// element. Purely presentational (caller supplies the already-computed
/// balance and currency symbol).
class BalanceWidget extends StatelessWidget {
  final double balance;
  final String currencySymbol;
  final String label;

  const BalanceWidget({
    super.key,
    required this.balance,
    this.currencySymbol = '\$',
    this.label = 'Current Balance',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$currencySymbol${balance.toAmount()}',
          style: context.textStyles.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
