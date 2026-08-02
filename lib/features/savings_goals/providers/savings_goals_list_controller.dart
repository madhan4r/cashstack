import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/failure.dart';
import '../models/savings_goal.dart';
import '../repositories/savings_goals_repository.dart';

enum SavingsGoalsListStatus { loading, loaded, error, refreshing }

class SavingsGoalsListState {
  final List<SavingsGoal> items;
  final SavingsGoalsListStatus status;
  final Failure? error;

  const SavingsGoalsListState({
    this.items = const [],
    this.status = SavingsGoalsListStatus.loading,
    this.error,
  });

  SavingsGoalsListState copyWith({
    List<SavingsGoal>? items,
    SavingsGoalsListStatus? status,
    Failure? error,
    bool clearError = false,
  }) {
    return SavingsGoalsListState(
      items: items ?? this.items,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Drives the Savings Goals list: initial load, pull-to-refresh, and local
/// mutation after create/edit/contribute/delete so the list reflects those
/// actions immediately without a full refetch.
class SavingsGoalsListController extends Notifier<SavingsGoalsListState> {
  @override
  SavingsGoalsListState build() {
    unawaited(_load());
    return const SavingsGoalsListState();
  }

  Future<void> _load() async {
    final repository = ref.read(savingsGoalsRepositoryProvider);
    try {
      final items = await repository.getGoals();
      state = state.copyWith(
        items: items,
        status: SavingsGoalsListStatus.loaded,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: SavingsGoalsListStatus.error,
        error: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: SavingsGoalsListStatus.refreshing);
    await _load();
  }

  void upsertLocal(SavingsGoal goal) {
    final index = state.items.indexWhere((g) => g.id == goal.id);
    final updated = [...state.items];
    if (index == -1) {
      updated.add(goal);
    } else {
      updated[index] = goal;
    }
    state = state.copyWith(items: updated);
  }

  void removeLocal(String id) {
    state = state.copyWith(items: state.items.where((g) => g.id != id).toList());
  }
}

final savingsGoalsListControllerProvider =
    NotifierProvider<SavingsGoalsListController, SavingsGoalsListState>(
      SavingsGoalsListController.new,
    );
