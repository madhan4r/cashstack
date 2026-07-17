import 'transaction_kind.dart';

/// One row of the dashboard's "recent transactions" list. Mirrors the
/// backend's `DashboardTransactionDto`.
class DashboardTransaction {
  final String id;
  final double amount;
  final TransactionKind kind;
  final String? accountName;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? notes;
  final String? paymentMethod;
  final DateTime transactionDate;

  const DashboardTransaction({
    required this.id,
    required this.amount,
    required this.kind,
    this.accountName,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.notes,
    this.paymentMethod,
    required this.transactionDate,
  });

  factory DashboardTransaction.fromJson(Map<String, dynamic> json) {
    return DashboardTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      kind: TransactionKind.fromJson(json['type'] as String),
      accountName: json['accountName'] as String?,
      categoryName: json['categoryName'] as String?,
      categoryIcon: json['categoryIcon'] as String?,
      categoryColor: json['categoryColor'] as String?,
      notes: json['notes'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
    );
  }
}
