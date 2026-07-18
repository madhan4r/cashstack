import 'package:flutter/material.dart';

/// Mirrors the backend's `PaymentMethod` enum.
enum PaymentMethod {
  cash('CASH', 'Cash', Icons.payments_outlined),
  card('CARD', 'Card', Icons.credit_card_outlined),
  upi('UPI', 'UPI', Icons.qr_code_rounded),
  bankTransfer('BANK_TRANSFER', 'Bank transfer', Icons.account_balance_outlined),
  other('OTHER', 'Other', Icons.more_horiz_rounded);

  final String queryValue;
  final String label;
  final IconData icon;

  const PaymentMethod(this.queryValue, this.label, this.icon);

  factory PaymentMethod.fromJson(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.queryValue == value,
      orElse: () => PaymentMethod.other,
    );
  }

  String toJson() => queryValue;
}
