import 'package:flutter/material.dart';

/// Mirrors the backend's `AccountType` enum. Each type carries its own
/// display label and icon so callers never need a separate lookup table.
enum AccountType {
  cash('CASH', 'Cash', Icons.payments_outlined),
  bank('BANK', 'Bank Account', Icons.account_balance_outlined),
  creditCard('CREDIT_CARD', 'Credit Card', Icons.credit_card_outlined),
  debitCard('DEBIT_CARD', 'Debit Card', Icons.payment_outlined),
  eWallet('EWALLET', 'Wallet', Icons.account_balance_wallet_outlined),
  upi('UPI', 'UPI', Icons.qr_code_rounded),
  investment('INVESTMENT', 'Investment', Icons.trending_up_rounded),
  savings('SAVINGS', 'Savings', Icons.savings_outlined);

  final String jsonValue;
  final String label;
  final IconData icon;

  const AccountType(this.jsonValue, this.label, this.icon);

  factory AccountType.fromJson(String value) => AccountType.values.firstWhere(
    (type) => type.jsonValue == value,
    orElse: () => AccountType.bank,
  );

  String toJson() => jsonValue;
}
