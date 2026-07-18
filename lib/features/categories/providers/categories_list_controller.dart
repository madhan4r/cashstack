import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../models/category.dart';
import '../models/category_type.dart';
import '../repositories/categories_repository.dart';
import 'categories_filter_provider.dart';
import 'categories_list_state.dart';

/// Drives the Categories list: initial load, pull-to-refresh, and local
/// mutation after archive/unarchive/delete so the list reflects those
/// actions immediately without a full refetch.
class CategoriesListController extends Notifier<CategoriesListState> {
  @override
  CategoriesListState build() {
    unawaited(_load());
    return const CategoriesListState();
  }

  Future<void> _load() async {
    final repository = ref.read(categoriesRepositoryProvider);
    try {
      final categories = await repository.getCategories();
      state = state.copyWith(
        categories: categories,
        status: CategoriesListStatus.loaded,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: CategoriesListStatus.error,
        error: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: CategoriesListStatus.refreshing);
    await _load();
  }

  void upsertLocal(Category category) {
    final index = state.categories.indexWhere((c) => c.id == category.id);
    final updated = [...state.categories];
    if (index == -1) {
      updated.add(category);
    } else {
      updated[index] = category;
    }
    state = state.copyWith(categories: updated);
  }

  void removeLocal(String categoryId) {
    state = state.copyWith(
      categories: state.categories.where((c) => c.id != categoryId).toList(),
    );
  }
}

final categoriesListControllerProvider =
    NotifierProvider<CategoriesListController, CategoriesListState>(
      CategoriesListController.new,
    );

/// The categories list after applying [categoriesFilterProvider]'s search
/// text, type, and archived-visibility filters.
final filteredCategoriesProvider = Provider<List<Category>>((ref) {
  final state = ref.watch(categoriesListControllerProvider);
  final filter = ref.watch(categoriesFilterProvider);

  var categories = state.categories;
  if (!filter.showArchived) {
    categories = categories.where((c) => !c.isArchived).toList();
  }
  if (filter.type != null) {
    categories = categories.where((c) => c.type == filter.type).toList();
  }
  final query = filter.search.trim().toLowerCase();
  if (query.isNotEmpty) {
    categories = categories.where((c) => c.name.toLowerCase().contains(query)).toList();
  }
  return categories;
});

/// Active (non-archived) categories only — what the Category Selector and
/// the transaction form should offer, regardless of the list screen's own
/// archived-visibility toggle.
final activeCategoriesProvider = Provider<List<Category>>((ref) {
  final state = ref.watch(categoriesListControllerProvider);
  return state.categories.where((c) => !c.isArchived).toList();
});

/// [activeCategoriesProvider] scoped to a single [CategoryType] — used by
/// the transaction form to show only Expense or Income categories.
final activeCategoriesByTypeProvider =
    Provider.family<List<Category>, CategoryType>((ref, type) {
  return ref.watch(activeCategoriesProvider).where((c) => c.type == type).toList();
});
