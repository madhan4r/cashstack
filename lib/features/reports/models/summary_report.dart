import 'package:equatable/equatable.dart';

/// Mirrors the backend's `SummaryReportDto` (`GET /reports/summary`).
class SummaryReport extends Equatable {
  final double currentBalance;
  final double totalIncome;
  final double totalExpense;
  final double netSavings;

  /// Already expressed 0-100 (e.g. `23.5` meaning 23.5%) — do NOT run
  /// through `NumFormattingX.toPercentage()`, which expects a 0-1 fraction.
  final double savingsRate;
  final int transactionCount;

  const SummaryReport({
    required this.currentBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRate,
    required this.transactionCount,
  });

  factory SummaryReport.fromJson(Map<String, dynamic> json) {
    return SummaryReport(
      currentBalance: (json['currentBalance'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpense: (json['totalExpense'] as num).toDouble(),
      netSavings: (json['netSavings'] as num).toDouble(),
      savingsRate: (json['savingsRate'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }

  @override
  List<Object?> get props => [
    currentBalance,
    totalIncome,
    totalExpense,
    netSavings,
    savingsRate,
    transactionCount,
  ];
}
