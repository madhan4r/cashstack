import 'package:equatable/equatable.dart';

/// Mirrors the backend's `MonthlyBreakdownItemDto` (part of `YearlyReportDto`).
class MonthlyBreakdownItem extends Equatable {
  final int month;
  final String label;
  final double income;
  final double expense;
  final double savings;

  const MonthlyBreakdownItem({
    required this.month,
    required this.label,
    required this.income,
    required this.expense,
    required this.savings,
  });

  factory MonthlyBreakdownItem.fromJson(Map<String, dynamic> json) {
    return MonthlyBreakdownItem(
      month: json['month'] as int,
      label: json['label'] as String,
      income: (json['income'] as num).toDouble(),
      expense: (json['expense'] as num).toDouble(),
      savings: (json['savings'] as num).toDouble(),
    );
  }

  /// Short month label for chart axes, e.g. `Jan`.
  String get shortLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [month, label, income, expense, savings];
}
