import 'package:equatable/equatable.dart';

/// Mirrors the backend's `CategoryBudgetResponseDto`.
class CategoryBudget extends Equatable {
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final double amount;
  final double spent;

  const CategoryBudget({
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.amount,
    required this.spent,
  });

  double get remaining => amount - spent;
  double get progress => amount <= 0 ? 0 : (spent / amount).clamp(0, 1);
  bool get isOverBudget => spent > amount;

  factory CategoryBudget.fromJson(Map<String, dynamic> json) {
    return CategoryBudget(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      categoryIcon: json['categoryIcon'] as String?,
      categoryColor: json['categoryColor'] as String?,
      amount: (json['amount'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    categoryIcon,
    categoryColor,
    amount,
    spent,
  ];
}
