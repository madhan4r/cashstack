import '../../../core/error/failure.dart';
import '../models/category.dart';
import '../models/category_type.dart';

/// State for [CategoryFormController]. `categoryId == null` means Add
/// mode; otherwise Edit mode, and [isLoadingInitial]/[loadError] reflect
/// fetching the existing category to populate the form.
class CategoryFormState {
  final String? categoryId;
  final bool isLoadingInitial;
  final Failure? loadError;

  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;
  final String description;

  final bool isDefault;
  final bool isArchived;
  final int transactionCount;

  /// Only shown once the user has attempted to submit.
  final bool showValidationErrors;
  final Map<String, String> fieldErrors;

  final bool isSubmitting;
  final bool isDeleting;
  final bool isTogglingArchive;
  final Failure? submitError;

  const CategoryFormState({
    this.categoryId,
    this.isLoadingInitial = false,
    this.loadError,
    this.name = '',
    this.type = CategoryType.expense,
    this.icon,
    this.color,
    this.description = '',
    this.isDefault = false,
    this.isArchived = false,
    this.transactionCount = 0,
    this.showValidationErrors = false,
    this.fieldErrors = const {},
    this.isSubmitting = false,
    this.isDeleting = false,
    this.isTogglingArchive = false,
    this.submitError,
  });

  bool get isEditMode => categoryId != null;

  /// Default categories can only be archived/unarchived, never edited or
  /// deleted — the backend rejects those requests outright.
  bool get isEditable => !isDefault;

  /// Per the spec: categories with transactions can only be archived;
  /// deletion (with confirmation) is offered only once there's nothing
  /// tying the category to existing data.
  bool get canDelete => isEditable && transactionCount == 0;

  factory CategoryFormState.initial({String? categoryId, CategoryType? initialType}) {
    return CategoryFormState(
      categoryId: categoryId,
      isLoadingInitial: categoryId != null,
      type: initialType ?? CategoryType.expense,
    );
  }

  factory CategoryFormState.fromCategory(Category category) {
    return CategoryFormState(
      categoryId: category.id,
      isLoadingInitial: false,
      name: category.name,
      type: category.type,
      icon: category.icon,
      color: category.color,
      description: category.description ?? '',
      isDefault: category.isDefault,
      isArchived: category.isArchived,
      transactionCount: category.transactionCount,
    );
  }

  CategoryFormState copyWith({
    bool? isLoadingInitial,
    Failure? loadError,
    bool clearLoadError = false,
    String? name,
    CategoryType? type,
    String? icon,
    String? color,
    String? description,
    bool? isArchived,
    bool? showValidationErrors,
    Map<String, String>? fieldErrors,
    bool? isSubmitting,
    bool? isDeleting,
    bool? isTogglingArchive,
    Failure? submitError,
    bool clearSubmitError = false,
  }) {
    return CategoryFormState(
      categoryId: categoryId,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      isDefault: isDefault,
      isArchived: isArchived ?? this.isArchived,
      transactionCount: transactionCount,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDeleting: isDeleting ?? this.isDeleting,
      isTogglingArchive: isTogglingArchive ?? this.isTogglingArchive,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}
