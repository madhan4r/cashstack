import '../../../shared/models/transaction_kind.dart';

enum DetectedTransactionStatus { pending, added, dismissed }

/// A transaction candidate detected from a bank notification, awaiting the
/// user's review — see `DetectedTransactionsController`. Never becomes a
/// real transaction on its own; the user has to confirm it (optionally
/// editing amount/account/category) on the Add Transaction form first.
class DetectedTransaction {
  final String id;
  final double amount;
  final TransactionKind type;
  final String sourceApp;
  final String rawText;
  final DateTime detectedAt;
  final DetectedTransactionStatus status;

  const DetectedTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.sourceApp,
    required this.rawText,
    required this.detectedAt,
    this.status = DetectedTransactionStatus.pending,
  });

  DetectedTransaction copyWith({DetectedTransactionStatus? status}) {
    return DetectedTransaction(
      id: id,
      amount: amount,
      type: type,
      sourceApp: sourceApp,
      rawText: rawText,
      detectedAt: detectedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'type': type.toJson(),
    'sourceApp': sourceApp,
    'rawText': rawText,
    'detectedAt': detectedAt.toIso8601String(),
    'status': status.name,
  };

  factory DetectedTransaction.fromJson(Map<String, dynamic> json) {
    return DetectedTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionKind.fromJson(json['type'] as String),
      sourceApp: json['sourceApp'] as String,
      rawText: json['rawText'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      status: DetectedTransactionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => DetectedTransactionStatus.pending,
      ),
    );
  }
}
