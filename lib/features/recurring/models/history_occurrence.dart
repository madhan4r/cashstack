import 'package:equatable/equatable.dart';

import 'occurrence_status.dart';

/// Mirrors the backend's `OccurrenceResponseDto` — a single past-due
/// history-log entry for a recurring transaction.
class HistoryOccurrence extends Equatable {
  final String id;
  final String recurringTransactionId;
  final String name;
  final double amount;
  final DateTime dueDate;
  final OccurrenceStatus status;
  final String? transactionId;

  const HistoryOccurrence({
    required this.id,
    required this.recurringTransactionId,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.transactionId,
  });

  factory HistoryOccurrence.fromJson(Map<String, dynamic> json) {
    return HistoryOccurrence(
      id: json['id'] as String,
      recurringTransactionId: json['recurringTransactionId'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String).toLocal(),
      status: OccurrenceStatus.fromJson(json['status'] as String),
      transactionId: json['transactionId'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    recurringTransactionId,
    name,
    amount,
    dueDate,
    status,
    transactionId,
  ];
}
