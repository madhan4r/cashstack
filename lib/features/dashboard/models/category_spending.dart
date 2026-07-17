/// One row of the "top spending categories" breakdown. Mirrors the
/// backend's `ExpenseByCategoryDto`.
class CategorySpending {
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final double total;
  final int transactionCount;
  final double percentage;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.total,
    required this.transactionCount,
    required this.percentage,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      categoryIcon: json['categoryIcon'] as String?,
      categoryColor: json['categoryColor'] as String?,
      total: (json['total'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}
