import '../../../core/error/failure.dart';
import '../models/category.dart';

enum CategoryDetailsStatus { loading, loaded, error }

/// State for [CategoryDetailsController].
class CategoryDetailsState {
  final Category? category;
  final CategoryDetailsStatus status;
  final Failure? error;
  final bool isTogglingArchive;

  const CategoryDetailsState({
    this.category,
    this.status = CategoryDetailsStatus.loading,
    this.error,
    this.isTogglingArchive = false,
  });

  CategoryDetailsState copyWith({
    Category? category,
    CategoryDetailsStatus? status,
    Failure? error,
    bool clearError = false,
    bool? isTogglingArchive,
  }) {
    return CategoryDetailsState(
      category: category ?? this.category,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      isTogglingArchive: isTogglingArchive ?? this.isTogglingArchive,
    );
  }
}
