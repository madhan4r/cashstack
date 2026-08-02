import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency.dart';
import 'auth_controller.dart';

/// The signed-in user's preferred currency, used as the display default
/// anywhere an amount isn't tied to a specific account (dashboard totals,
/// reports, recurring schedules). Falls back to INR if the user hasn't set
/// one or hasn't loaded yet.
final preferredCurrencyProvider = Provider<CurrencyOption>((ref) {
  final code = ref.watch(authControllerProvider).user?.preferredCurrency;
  return supportedCurrencies.firstWhere(
    (c) => c.code == code,
    orElse: () => supportedCurrencies.first,
  );
});

final preferredCurrencySymbolProvider = Provider<String>((ref) {
  return ref.watch(preferredCurrencyProvider).symbol;
});
