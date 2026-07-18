import 'package:equatable/equatable.dart';

/// A single account's ledger summary, as returned by
/// `GET /accounts/:id/stats` — total income, total expense, and
/// transaction count computed from every transaction touching the account.
class AccountStats extends Equatable {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final int transactionCount;

  const AccountStats({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactionCount,
  });

  double get netBalance => totalIncome - totalExpense;

  factory AccountStats.fromJson(Map<String, dynamic> json) {
    return AccountStats(
      balance: (json['balance'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpense: (json['totalExpense'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }

  @override
  List<Object?> get props => [balance, totalIncome, totalExpense, transactionCount];
}
