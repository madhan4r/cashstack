import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/result.dart';
import '../../accounts/providers/accounts_list_controller.dart';
import '../../budget/providers/category_budgets_controller.dart';
import '../../categories/providers/categories_list_controller.dart';
import '../../dashboard/providers/dashboard_controller.dart';
import '../../recurring/providers/recurring_list_controller.dart';
import '../../reports/providers/reports_controller.dart';
import '../../savings_goals/providers/savings_goals_list_controller.dart';
import '../../transactions/providers/reference_data_provider.dart';
import '../../transactions/providers/transactions_list_controller.dart';
import '../models/household.dart';
import '../repositories/household_repository.dart';

/// Every cache whose contents depend on household scope (combined vs.
/// separate, or membership itself) — invalidated whenever that scope
/// changes, so no screen keeps showing data fetched under the old scope.
/// Takes a plain [Ref] (rather than [WidgetRef], see
/// `core/session/user_scoped_providers.dart`) so it works from inside a
/// Notifier, not just a widget.
void invalidateScopedData(Ref ref) {
  ref.invalidate(dashboardControllerProvider);
  ref.invalidate(accountsListControllerProvider);
  ref.invalidate(categoriesListControllerProvider);
  ref.invalidate(referenceDataProvider);
  ref.invalidate(transactionsListControllerProvider);
  ref.invalidate(reportsControllerProvider);
  ref.invalidate(recurringListControllerProvider);
  ref.invalidate(categoryBudgetsControllerProvider);
  ref.invalidate(savingsGoalsListControllerProvider);
}

/// The caller's current household, or `null` if they're not in one.
class HouseholdController extends AsyncNotifier<Household?> {
  @override
  Future<Household?> build() {
    return ref.watch(householdRepositoryProvider).getMyHousehold();
  }

  Future<void> refresh() async {
    final repository = ref.read(householdRepositoryProvider);
    state = await AsyncValue.guard(repository.getMyHousehold);
  }

  Future<Result<void>> invite(String email) async {
    try {
      await ref.read(householdRepositoryProvider).inviteMember(email);
      await refresh();
      return const Result.ok(null);
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }

  Future<Result<void>> leave() async {
    try {
      await ref.read(householdRepositoryProvider).leaveHousehold();
      await refresh();
      invalidateScopedData(ref);
      return const Result.ok(null);
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }

  Future<Result<void>> setViewMode(HouseholdViewMode mode) async {
    try {
      await ref.read(householdRepositoryProvider).setViewMode(mode);
      await refresh();
      invalidateScopedData(ref);
      return const Result.ok(null);
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }
}

final householdControllerProvider =
    AsyncNotifierProvider<HouseholdController, Household?>(
      HouseholdController.new,
    );
