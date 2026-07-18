import 'package:equatable/equatable.dart';

/// Mirrors the backend's `CategoryBreakdownItemDto` — the shape shared by
/// `MonthlyReportDto`'s category arrays and `GET /reports/category`'s
/// items. `percentage` is already 0-100.
class CategoryBreakdownItem extends Equatable {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
  final int transactionCount;

  const CategoryBreakdownItem({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  factory CategoryBreakdownItem.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownItem(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }

  @override
  List<Object?> get props => [categoryId, categoryName, amount, percentage, transactionCount];
}
