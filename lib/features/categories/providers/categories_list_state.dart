import '../../../core/error/failure.dart';
import '../models/category.dart';

enum CategoriesListStatus { loading, refreshing, loaded, error }

/// State for [CategoriesListController]. The backend returns the full,
/// unpaginated category list in one call, so there's no infinite-scroll
/// status — just loading/refreshing/loaded/error.
class CategoriesListState {
  final List<Category> categories;
  final CategoriesListStatus status;
  final Failure? error;

  const CategoriesListState({
    this.categories = const [],
    this.status = CategoriesListStatus.loading,
    this.error,
  });

  bool get isInitialLoading =>
      status == CategoriesListStatus.loading && categories.isEmpty;

  CategoriesListState copyWith({
    List<Category>? categories,
    CategoriesListStatus? status,
    Failure? error,
    bool clearError = false,
  }) {
    return CategoriesListState(
      categories: categories ?? this.categories,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
