import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../models/category_budget.dart';
import '../repositories/category_budget_repository.dart';

enum CategoryBudgetsStatus { loading, loaded, error, refreshing }

class CategoryBudgetsState {
  final List<CategoryBudget> items;
  final CategoryBudgetsStatus status;
  final Failure? error;

  const CategoryBudgetsState({
    this.items = const [],
    this.status = CategoryBudgetsStatus.loading,
    this.error,
  });

  CategoryBudgetsState copyWith({
    List<CategoryBudget>? items,
    CategoryBudgetsStatus? status,
    Failure? error,
    bool clearError = false,
  }) {
    return CategoryBudgetsState(
      items: items ?? this.items,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Drives the Category Budgets screen: initial load, pull-to-refresh, and
/// local mutation after set/clear so the list reflects those actions
/// immediately without a full refetch.
class CategoryBudgetsController extends Notifier<CategoryBudgetsState> {
  @override
  CategoryBudgetsState build() {
    unawaited(_load());
    return const CategoryBudgetsState();
  }

  Future<void> _load() async {
    final repository = ref.read(categoryBudgetRepositoryProvider);
    try {
      final items = await repository.getAll();
      state = state.copyWith(
        items: items,
        status: CategoryBudgetsStatus.loaded,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: CategoryBudgetsStatus.error,
        error: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: CategoryBudgetsStatus.refreshing);
    await _load();
  }

  Future<Result<void>> setBudget(String categoryId, double amount) async {
    final repository = ref.read(categoryBudgetRepositoryProvider);
    try {
      await repository.set(categoryId, amount);
      await _load();
      return const Result.ok(null);
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }

  Future<Result<void>> clearBudget(String categoryId) async {
    final repository = ref.read(categoryBudgetRepositoryProvider);
    try {
      await repository.clear(categoryId);
      state = state.copyWith(
        items: state.items.where((b) => b.categoryId != categoryId).toList(),
      );
      return const Result.ok(null);
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }
}

final categoryBudgetsControllerProvider =
    NotifierProvider<CategoryBudgetsController, CategoryBudgetsState>(
      CategoryBudgetsController.new,
    );
