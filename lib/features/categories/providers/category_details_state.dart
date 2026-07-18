import '../../../core/error/failure.dart';
import '../models/category.dart';

enum CategoryDetailsStatus { loading, loaded, error }

/// State for [CategoryDetailsController].
class CategoryDetailsState {
  final Category? category;
  final CategoryDetailsStatus status;
  final Failure? error;

  const CategoryDetailsState({
    this.category,
    this.status = CategoryDetailsStatus.loading,
    this.error,
  });

  CategoryDetailsState copyWith({
    Category? category,
    CategoryDetailsStatus? status,
    Failure? error,
    bool clearError = false,
  }) {
    return CategoryDetailsState(
      category: category ?? this.category,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
