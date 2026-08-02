import 'category_spending.dart';
import 'dashboard_transaction.dart';
import 'monthly_trend_point.dart';

/// The full `GET /dashboard` response. Mirrors the backend's
/// `DashboardDataDto`.
class DashboardData {
  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlySavings;

  /// The user's set monthly budget, or `null` if they haven't set one.
  final double? monthlyBudget;

  /// `monthlyBudget` minus `monthlyExpense`; 0 when no budget is set.
  final double budgetRemaining;

  final List<DashboardTransaction> recentTransactions;
  final List<CategorySpending> expenseByCategory;
  final List<MonthlyTrendPoint> monthlyTrend;

  const DashboardData({
    required this.currentBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlySavings,
    required this.monthlyBudget,
    required this.budgetRemaining,
    required this.recentTransactions,
    required this.expenseByCategory,
    required this.monthlyTrend,
  });

  /// True when the user has never recorded a transaction — the dashboard
  /// shows [DashboardEmptyState] instead of the full layout in this case.
  bool get hasNoActivity => recentTransactions.isEmpty;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      currentBalance: (json['currentBalance'] as num).toDouble(),
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      monthlyExpense: (json['monthlyExpense'] as num).toDouble(),
      monthlySavings: (json['monthlySavings'] as num).toDouble(),
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble(),
      budgetRemaining: (json['budgetRemaining'] as num).toDouble(),
      recentTransactions: (json['recentTransactions'] as List<dynamic>)
          .map((e) => DashboardTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenseByCategory: (json['expenseByCategory'] as List<dynamic>)
          .map((e) => CategorySpending.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyTrend: (json['monthlyTrend'] as List<dynamic>)
          .map((e) => MonthlyTrendPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
