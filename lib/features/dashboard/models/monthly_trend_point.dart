/// One point of the 6-month income/expense/savings trend. Mirrors the
/// backend's `MonthlyTrendDto`.
class MonthlyTrendPoint {
  final int year;
  final int month;
  final String label;
  final double income;
  final double expense;
  final double savings;

  const MonthlyTrendPoint({
    required this.year,
    required this.month,
    required this.label,
    required this.income,
    required this.expense,
    required this.savings,
  });

  factory MonthlyTrendPoint.fromJson(Map<String, dynamic> json) {
    return MonthlyTrendPoint(
      year: json['year'] as int,
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
}
