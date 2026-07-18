import 'package:equatable/equatable.dart';

import '../../../shared/models/transaction_kind.dart';

/// Mirrors the backend's `UpcomingOccurrenceDto` — a projected (not yet
/// generated) future due date for a schedule preview.
class UpcomingOccurrence extends Equatable {
  final String recurringTransactionId;
  final String name;
  final TransactionKind type;
  final double amount;
  final String categoryId;
  final String accountId;
  final DateTime dueDate;

  const UpcomingOccurrence({
    required this.recurringTransactionId,
    required this.name,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    required this.dueDate,
  });

  factory UpcomingOccurrence.fromJson(Map<String, dynamic> json) {
    return UpcomingOccurrence(
      recurringTransactionId: json['recurringTransactionId'] as String,
      name: json['name'] as String,
      type: TransactionKind.fromJson(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      accountId: json['accountId'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String).toLocal(),
    );
  }

  @override
  List<Object?> get props => [
    recurringTransactionId,
    name,
    type,
    amount,
    categoryId,
    accountId,
    dueDate,
  ];
}
