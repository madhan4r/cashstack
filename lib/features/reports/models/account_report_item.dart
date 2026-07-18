import 'package:equatable/equatable.dart';

/// Mirrors the backend's `AccountReportItemDto` (part of `GET /reports/account`).
class AccountReportItem extends Equatable {
  final String accountId;
  final String accountName;
  final double income;
  final double expense;
  final double currentBalance;
  final int transactionCount;

  const AccountReportItem({
    required this.accountId,
    required this.accountName,
    required this.income,
    required this.expense,
    required this.currentBalance,
    required this.transactionCount,
  });

  factory AccountReportItem.fromJson(Map<String, dynamic> json) {
    return AccountReportItem(
      accountId: json['accountId'] as String,
      accountName: json['accountName'] as String,
      income: (json['income'] as num).toDouble(),
      expense: (json['expense'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }

  @override
  List<Object?> get props => [
    accountId,
    accountName,
    income,
    expense,
    currentBalance,
    transactionCount,
  ];
}
