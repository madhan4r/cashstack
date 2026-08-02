import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../models/savings_goal.dart';
import '../models/savings_goal_form_data.dart';
import '../repositories/savings_goals_repository.dart';
import 'savings_goal_form_state.dart';
import 'savings_goals_list_controller.dart';

/// Drives the Add/Edit/Detail Savings Goal screen. Keyed by `goalId`
/// (`null` for Add mode) so editing a different goal — or opening a fresh
/// Add screen — always starts from clean state; `autoDispose` tears it
/// down when the screen is popped.
class SavingsGoalFormController extends Notifier<SavingsGoalFormState> {
  final String? goalId;

  SavingsGoalFormController(this.goalId);

  @override
  SavingsGoalFormState build() {
    final id = goalId;
    if (id != null) {
      unawaited(_loadExisting(id));
    }
    return SavingsGoalFormState.initial(goalId: id);
  }

  Future<void> _loadExisting(String id) async {
    final repository = ref.read(savingsGoalsRepositoryProvider);
    try {
      final goal = await repository.getGoal(id);
      state = SavingsGoalFormState.fromGoal(goal);
    } catch (error) {
      state = state.copyWith(
        isLoadingInitial: false,
        loadError: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> retryLoad() async {
    final id = state.goalId;
    if (id == null) return;
    state = state.copyWith(isLoadingInitial: true, clearLoadError: true);
    await _loadExisting(id);
  }

  void setName(String name) => state = state.copyWith(name: name);

  void setTargetAmount(double amount) => state = state.copyWith(targetAmount: amount);

  void setTargetDate(DateTime? date) =>
      state = state.copyWith(targetDate: date, clearTargetDate: date == null);

  void setIcon(String icon) => state = state.copyWith(icon: icon);

  void setColor(String color) => state = state.copyWith(color: color);

  Future<Result<SavingsGoal>> submit() async {
    final errors = _validate(state);
    state = state.copyWith(
      fieldErrors: errors,
      showValidationErrors: true,
      clearSubmitError: true,
    );

    if (errors.isNotEmpty) {
      return const Result.err(ValidationFailure(message: 'Please fix the highlighted fields'));
    }

    state = state.copyWith(isSubmitting: true);
    final repository = ref.read(savingsGoalsRepositoryProvider);
    final data = SavingsGoalFormData(
      name: state.name,
      targetAmount: state.targetAmount!,
      targetDate: state.targetDate,
      icon: state.icon,
      color: state.color,
    );

    try {
      final saved = state.isEditMode
          ? await repository.updateGoal(state.goalId!, data)
          : await repository.createGoal(data);

      ref.read(savingsGoalsListControllerProvider.notifier).upsertLocal(saved);
      state = state.copyWith(isSubmitting: false, currentAmount: saved.currentAmount);
      return Result.ok(saved);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isSubmitting: false, submitError: failure);
      return Result.err(failure);
    }
  }

  /// [amount] positive to contribute, negative to withdraw.
  Future<Result<SavingsGoal>> contribute(double amount) async {
    final id = state.goalId;
    if (id == null) return const Result.err(UnknownFailure());

    state = state.copyWith(isContributing: true, clearSubmitError: true);
    final repository = ref.read(savingsGoalsRepositoryProvider);

    try {
      final updated = await repository.contribute(id, amount);
      ref.read(savingsGoalsListControllerProvider.notifier).upsertLocal(updated);
      state = state.copyWith(isContributing: false, currentAmount: updated.currentAmount);
      return Result.ok(updated);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isContributing: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Future<Result<void>> delete() async {
    final id = state.goalId;
    if (id == null) return const Result.ok(null);

    state = state.copyWith(isDeleting: true, clearSubmitError: true);
    final repository = ref.read(savingsGoalsRepositoryProvider);

    try {
      await repository.deleteGoal(id);
      ref.read(savingsGoalsListControllerProvider.notifier).removeLocal(id);
      state = state.copyWith(isDeleting: false);
      return const Result.ok(null);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isDeleting: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Map<String, String> _validate(SavingsGoalFormState s) {
    final errors = <String, String>{};

    if (s.name.trim().isEmpty) {
      errors['name'] = 'Enter a name';
    }
    if (s.targetAmount == null || s.targetAmount! <= 0) {
      errors['targetAmount'] = 'Enter an amount greater than 0';
    }

    return errors;
  }
}

final savingsGoalFormControllerProvider = NotifierProvider.autoDispose
    .family<SavingsGoalFormController, SavingsGoalFormState, String?>(
      SavingsGoalFormController.new,
    );
