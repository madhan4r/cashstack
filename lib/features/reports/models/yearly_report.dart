import 'package:equatable/equatable.dart';

import 'monthly_breakdown_item.dart';

/// Mirrors the backend's `YearlyReportDto` (`GET /reports/yearly`).
class YearlyReport extends Equatable {
  final int year;
  final List<MonthlyBreakdownItem> monthlyBreakdown;
  final MonthlyBreakdownItem? highestSpendingMonth;
  final MonthlyBreakdownItem? highestIncomeMonth;
  final double averageMonthlyExpense;
  final double averageMonthlyIncome;

  const YearlyReport({
    required this.year,
    required this.monthlyBreakdown,
    this.highestSpendingMonth,
    this.highestIncomeMonth,
    required this.averageMonthlyExpense,
    required this.averageMonthlyIncome,
  });

  factory YearlyReport.fromJson(Map<String, dynamic> json) {
    return YearlyReport(
      year: json['year'] as int,
      monthlyBreakdown: (json['monthlyBreakdown'] as List<dynamic>)
          .map((e) => MonthlyBreakdownItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      highestSpendingMonth: json['highestSpendingMonth'] == null
          ? null
          : MonthlyBreakdownItem.fromJson(
              json['highestSpendingMonth'] as Map<String, dynamic>,
            ),
      highestIncomeMonth: json['highestIncomeMonth'] == null
          ? null
          : MonthlyBreakdownItem.fromJson(
              json['highestIncomeMonth'] as Map<String, dynamic>,
            ),
      averageMonthlyExpense: (json['averageMonthlyExpense'] as num).toDouble(),
      averageMonthlyIncome: (json['averageMonthlyIncome'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    year,
    monthlyBreakdown,
    highestSpendingMonth,
    highestIncomeMonth,
    averageMonthlyExpense,
    averageMonthlyIncome,
  ];
}
