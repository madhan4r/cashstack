import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/result.dart';
import '../../dashboard/providers/dashboard_controller.dart';
import '../repositories/budget_repository.dart';

/// Drives the Set/Change/Remove Budget flow. Doesn't hold its own "current
/// budget" state — the Dashboard already fetches `monthlyBudget` as part
/// of its own payload, so this controller only needs to perform the
/// mutation and then invalidate the dashboard to pick up the new value.
class BudgetController extends Notifier<bool> {
  @override
  bool build() => false; // isSubmitting

  Future<Result<double>> setBudget(double amount) async {
    state = true;
    final repository = ref.read(budgetRepositoryProvider);
    try {
      final saved = await repository.setBudget(amount);
      ref.invalidate(dashboardControllerProvider);
      state = false;
      return Result.ok(saved);
    } catch (error) {
      state = false;
      return Result.err(mapExceptionToFailure(error));
    }
  }

  Future<Result<void>> clearBudget() async {
    state = true;
    final repository = ref.read(budgetRepositoryProvider);
    try {
      await repository.clearBudget();
      ref.invalidate(dashboardControllerProvider);
      state = false;
      return const Result.ok(null);
    } catch (error) {
      state = false;
      return Result.err(mapExceptionToFailure(error));
    }
  }
}

final budgetControllerProvider = NotifierProvider<BudgetController, bool>(
  BudgetController.new,
);
