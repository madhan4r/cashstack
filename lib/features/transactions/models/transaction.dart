import 'package:equatable/equatable.dart';

import '../../../shared/models/transaction_kind.dart';
import 'payment_method.dart';

/// A single transaction, as returned by `GET /transactions`. Mirrors the
/// backend's `TransactionResponseDto` — note it carries raw
/// `categoryId`/`accountId` references, not names; the UI enriches those
/// via the reference-data cache (see `reference_data_provider.dart`)
/// rather than the backend duplicating category/account data on every row.
class Transaction extends Equatable {
  final String id;
  final double amount;
  final TransactionKind kind;
  final String? accountId;
  final String? categoryId;
  final String? fromAccountId;
  final String? toAccountId;
  final String? notes;
  final PaymentMethod? paymentMethod;
  final DateTime transactionDate;
  final List<String> tags;

  const Transaction({
    required this.id,
    required this.amount,
    required this.kind,
    this.accountId,
    this.categoryId,
    this.fromAccountId,
    this.toAccountId,
    this.notes,
    this.paymentMethod,
    required this.transactionDate,
    this.tags = const [],
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final paymentMethodJson = json['paymentMethod'] as String?;
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      kind: TransactionKind.fromJson(json['type'] as String),
      accountId: json['accountId'] as String?,
      categoryId: json['categoryId'] as String?,
      fromAccountId: json['fromAccountId'] as String?,
      toAccountId: json['toAccountId'] as String?,
      notes: json['notes'] as String?,
      paymentMethod: paymentMethodJson == null
          ? null
          : PaymentMethod.fromJson(paymentMethodJson),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    kind,
    accountId,
    categoryId,
    fromAccountId,
    toAccountId,
    notes,
    paymentMethod,
    transactionDate,
    tags,
  ];
}
