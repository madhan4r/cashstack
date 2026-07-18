import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../repositories/categories_repository.dart';
import 'category_details_state.dart';

/// Drives the Category Detail screen's header/stats — keyed by
/// `categoryId`, `autoDispose` so it tears down when the screen is popped.
class CategoryDetailsController extends Notifier<CategoryDetailsState> {
  final String categoryId;

  CategoryDetailsController(this.categoryId);

  @override
  CategoryDetailsState build() {
    unawaited(_load());
    return const CategoryDetailsState();
  }

  Future<void> _load() async {
    final repository = ref.read(categoriesRepositoryProvider);
    try {
      final category = await repository.getCategory(categoryId);
      state = state.copyWith(
        category: category,
        status: CategoryDetailsStatus.loaded,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: CategoryDetailsStatus.error,
        error: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> refresh() => _load();
}

final categoryDetailsControllerProvider = NotifierProvider.autoDispose
    .family<CategoryDetailsController, CategoryDetailsState, String>(
      CategoryDetailsController.new,
    );
