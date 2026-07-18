import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/category_preferences_repository.dart';

class CategoryPreferencesState {
  final List<String> favoriteIds;
  final List<String> recentIds;

  const CategoryPreferencesState({
    this.favoriteIds = const [],
    this.recentIds = const [],
  });

  bool isFavorite(String categoryId) => favoriteIds.contains(categoryId);
}

/// Reactive wrapper around [CategoryPreferencesRepository] so the Category
/// Selector updates immediately when a favorite is toggled or a category is
/// used.
class CategoryPreferencesController extends Notifier<CategoryPreferencesState> {
  @override
  CategoryPreferencesState build() {
    final repository = ref.watch(categoryPreferencesRepositoryProvider);
    return CategoryPreferencesState(
      favoriteIds: repository.getFavoriteIds(),
      recentIds: repository.getRecentIds(),
    );
  }

  Future<void> toggleFavorite(String categoryId) async {
    final repository = ref.read(categoryPreferencesRepositoryProvider);
    await repository.toggleFavorite(categoryId);
    state = CategoryPreferencesState(
      favoriteIds: repository.getFavoriteIds(),
      recentIds: state.recentIds,
    );
  }

  Future<void> recordUsed(String categoryId) async {
    final repository = ref.read(categoryPreferencesRepositoryProvider);
    await repository.recordUsed(categoryId);
    state = CategoryPreferencesState(
      favoriteIds: state.favoriteIds,
      recentIds: repository.getRecentIds(),
    );
  }
}

final categoryPreferencesProvider =
    NotifierProvider<CategoryPreferencesController, CategoryPreferencesState>(
      CategoryPreferencesController.new,
    );
