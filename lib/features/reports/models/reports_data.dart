import '../../transactions/models/transaction.dart';
import 'account_report_item.dart';
import 'category_breakdown_item.dart';
import 'daily_breakdown_item.dart';
import 'monthly_breakdown_item.dart';
import 'summary_report.dart';

/// Everything the Reports Dashboard screen renders, fetched together for
/// the active [ReportFilter] — one bundle so [ReportsController] can expose
/// a single `AsyncValue` and the screen gets loading/error/data for the
/// whole dashboard at once, matching how `DashboardController` is built.
class ReportsData {
  final SummaryReport summary;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final List<AccountReportItem> accountBreakdown;
  final List<MonthlyBreakdownItem> monthlyTrend;
  final List<DailyBreakdownItem> dailySpending;
  final Transaction? largestTransaction;

  const ReportsData({
    required this.summary,
    required this.categoryBreakdown,
    required this.accountBreakdown,
    required this.monthlyTrend,
    required this.dailySpending,
    this.largestTransaction,
  });

  /// The single largest transaction category for the current filter, used
  /// by the "Highest spending category" insight.
  CategoryBreakdownItem? get highestSpendingCategory =>
      categoryBreakdown.isEmpty ? null : categoryBreakdown.first;

  /// The account with the most transactions touching it in this window,
  /// used by the "Most used account" insight.
  AccountReportItem? get mostUsedAccount {
    if (accountBreakdown.isEmpty) return null;
    return accountBreakdown.reduce(
      (a, b) => b.transactionCount > a.transactionCount ? b : a,
    );
  }

  /// The category with the most transactions in this window, used by the
  /// "Most used category" insight.
  CategoryBreakdownItem? get mostUsedCategory {
    if (categoryBreakdown.isEmpty) return null;
    return categoryBreakdown.reduce(
      (a, b) => b.transactionCount > a.transactionCount ? b : a,
    );
  }

  double get averageDailySpending {
    if (dailySpending.isEmpty) return 0;
    final total = dailySpending.fold<double>(0, (sum, day) => sum + day.expense);
    return total / dailySpending.length;
  }
}
