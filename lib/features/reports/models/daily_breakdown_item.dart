import 'package:equatable/equatable.dart';

/// Mirrors the backend's `DailyBreakdownItemDto` (part of `MonthlyReportDto`).
class DailyBreakdownItem extends Equatable {
  final int day;
  final DateTime date;
  final double income;
  final double expense;
  final double savings;

  const DailyBreakdownItem({
    required this.day,
    required this.date,
    required this.income,
    required this.expense,
    required this.savings,
  });

  factory DailyBreakdownItem.fromJson(Map<String, dynamic> json) {
    return DailyBreakdownItem(
      day: json['day'] as int,
      date: DateTime.parse(json['date'] as String),
      income: (json['income'] as num).toDouble(),
      expense: (json['expense'] as num).toDouble(),
      savings: (json['savings'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [day, date, income, expense, savings];
}
