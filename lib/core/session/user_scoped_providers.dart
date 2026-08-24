import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/accounts/providers/accounts_filter_provider.dart';
import '../../features/accounts/providers/accounts_list_controller.dart';
import '../../features/budget/providers/category_budgets_controller.dart';
import '../../features/categories/providers/categories_filter_provider.dart';
import '../../features/categories/providers/categories_list_controller.dart';
import '../../features/categories/providers/category_preferences_provider.dart';
import '../../features/dashboard/providers/dashboard_controller.dart';
import '../../features/household/providers/household_controller.dart';
import '../../features/household/providers/pending_invites_controller.dart';
import '../../features/notifications/providers/notifications_controller.dart';
import '../../features/recurring/providers/recurring_filter_provider.dart';
import '../../features/recurring/providers/recurring_list_controller.dart';
import '../../features/reports/providers/reports_controller.dart';
import '../../features/reports/providers/reports_filter_provider.dart';
import '../../features/savings_goals/providers/savings_goals_list_controller.dart';
import '../../features/transactions/providers/reference_data_provider.dart';
import '../../features/transactions/providers/transaction_filter_provider.dart';
import '../../features/transactions/providers/transactions_list_controller.dart';

/// Every long-lived (non-autoDispose) provider that caches data or filter
/// selections scoped to the signed-in user. None of these know about the
/// others or about auth — [resetUserScopedProviders] is the single place
/// that resets all of them together whenever the signed-in user changes
/// (login, logout, or switching accounts), so no screen ever renders the
/// previous user's cached accounts/transactions/reports/etc.
void resetUserScopedProviders(WidgetRef ref) {
  ref.invalidate(dashboardControllerProvider);
  ref.invalidate(accountsListControllerProvider);
  ref.invalidate(accountsFilterProvider);
  ref.invalidate(categoriesListControllerProvider);
  ref.invalidate(categoriesFilterProvider);
  ref.invalidate(categoryPreferencesProvider);
  ref.invalidate(referenceDataProvider);
  ref.invalidate(transactionsListControllerProvider);
  ref.invalidate(transactionFilterProvider);
  ref.invalidate(reportsControllerProvider);
  ref.invalidate(reportsFilterProvider);
  ref.invalidate(recurringListControllerProvider);
  ref.invalidate(recurringFilterProvider);
  ref.invalidate(categoryBudgetsControllerProvider);
  ref.invalidate(savingsGoalsListControllerProvider);
  ref.invalidate(householdControllerProvider);
  ref.invalidate(pendingInvitesControllerProvider);
  ref.invalidate(notificationsControllerProvider);
}

/// Every cache that a single transaction create/update/delete can affect:
/// the dashboard's totals/recent list, the transactions list itself,
/// account balances (shown via [referenceDataProvider] and the accounts
/// list), and report figures. Call this after any transaction mutation
/// instead of invalidating `transactionsListControllerProvider` alone.
void invalidateAfterTransactionChange(WidgetRef ref) {
  ref.invalidate(dashboardControllerProvider);
  ref.invalidate(transactionsListControllerProvider);
  ref.invalidate(referenceDataProvider);
  ref.invalidate(accountsListControllerProvider);
  ref.invalidate(reportsControllerProvider);
  ref.invalidate(categoryBudgetsControllerProvider);
}
