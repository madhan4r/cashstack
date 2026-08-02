import 'dart:io';

import 'package:home_widget/home_widget.dart';

import '../extensions/num_extensions.dart';

/// Pushes Dashboard data to the "Balance & Budget" home-screen widget
/// (Android only — the widget itself doesn't exist on other platforms).
/// The widget's Kotlin provider only ever reads what was last saved here;
/// it never fetches anything on its own.
class HomeWidgetSyncService {
  const HomeWidgetSyncService();

  Future<void> syncDashboard({
    required double balance,
    required double monthlyIncome,
    required double monthlyExpense,
    required double? monthlyBudget,
    required String currencySymbol,
  }) async {
    if (!Platform.isAndroid) return;

    await HomeWidget.saveWidgetData<String>(
      'balance_display',
      balance.toCurrency(symbol: currencySymbol, decimalDigits: 0),
    );
    await HomeWidget.saveWidgetData<String>(
      'income_display',
      monthlyIncome.toCurrency(symbol: currencySymbol, decimalDigits: 0),
    );
    await HomeWidget.saveWidgetData<String>(
      'expense_display',
      monthlyExpense.toCurrency(symbol: currencySymbol, decimalDigits: 0),
    );

    final hasBudget = monthlyBudget != null && monthlyBudget > 0;
    await HomeWidget.saveWidgetData<bool>('has_budget', hasBudget);
    if (hasBudget) {
      final progress = ((monthlyExpense / monthlyBudget) * 100).clamp(0, 100).round();
      await HomeWidget.saveWidgetData<int>('budget_progress', progress);
      await HomeWidget.saveWidgetData<String>(
        'budget_label',
        '${monthlyExpense.toCurrency(symbol: currencySymbol, decimalDigits: 0)} of '
            '${monthlyBudget.toCurrency(symbol: currencySymbol, decimalDigits: 0)}',
      );
    }

    await HomeWidget.updateWidget(androidName: 'BalanceWidgetProvider');
  }
}

const homeWidgetSyncService = HomeWidgetSyncService();
