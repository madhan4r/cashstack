import 'package:equatable/equatable.dart';

import 'category_breakdown_item.dart';
import 'daily_breakdown_item.dart';

/// Mirrors the backend's `MonthlyReportDto` (`GET /reports/monthly`).
class MonthlyReport extends Equatable {
  final int year;
  final int month;
  final double income;
  final double expense;
  final double savings;
  final List<DailyBreakdownItem> dailyBreakdown;
  final List<CategoryBreakdownItem> expenseByCategory;
  final List<CategoryBreakdownItem> incomeByCategory;
  final List<CategoryBreakdownItem> topSpendingCategories;
  final List<CategoryBreakdownItem> topIncomeSources;

  const MonthlyReport({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
    required this.savings,
    required this.dailyBreakdown,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.topSpendingCategories,
    required this.topIncomeSources,
  });

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    List<CategoryBreakdownItem> categories(String key) =>
        (json[key] as List<dynamic>)
            .map((e) => CategoryBreakdownItem.fromJson(e as Map<String, dynamic>))
            .toList();

    return MonthlyReport(
      year: json['year'] as int,
      month: json['month'] as int,
      income: (json['income'] as num).toDouble(),
      expense: (json['expense'] as num).toDouble(),
      savings: (json['savings'] as num).toDouble(),
      dailyBreakdown: (json['dailyBreakdown'] as List<dynamic>)
          .map((e) => DailyBreakdownItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenseByCategory: categories('expenseByCategory'),
      incomeByCategory: categories('incomeByCategory'),
      topSpendingCategories: categories('topSpendingCategories'),
      topIncomeSources: categories('topIncomeSources'),
    );
  }

  @override
  List<Object?> get props => [
    year,
    month,
    income,
    expense,
    savings,
    dailyBreakdown,
    expenseByCategory,
    incomeByCategory,
    topSpendingCategories,
    topIncomeSources,
  ];
}
