import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../models/category.dart';
import '../models/category_form_data.dart';
import '../models/category_type.dart';
import '../repositories/categories_repository.dart';
import 'categories_list_controller.dart';
import 'category_form_state.dart';

/// Drives the Add/Edit Category form. Keyed by `categoryId` (`null` for
/// Add mode) so editing a different category — or opening a fresh Add
/// screen — always starts from clean state; `autoDispose` tears it down
/// when the form screen is popped.
class CategoryFormController extends Notifier<CategoryFormState> {
  final String? categoryId;

  CategoryFormController(this.categoryId);

  @override
  CategoryFormState build() {
    final id = categoryId;
    if (id != null) {
      unawaited(_loadExisting(id));
    }
    return CategoryFormState.initial(categoryId: id);
  }

  Future<void> _loadExisting(String id) async {
    final repository = ref.read(categoriesRepositoryProvider);
    try {
      final category = await repository.getCategory(id);
      state = CategoryFormState.fromCategory(category);
    } catch (error) {
      state = state.copyWith(
        isLoadingInitial: false,
        loadError: mapExceptionToFailure(error),
      );
    }
  }

  Future<void> retryLoad() async {
    final id = state.categoryId;
    if (id == null) return;
    state = state.copyWith(isLoadingInitial: true, clearLoadError: true);
    await _loadExisting(id);
  }

  void setName(String name) => state = state.copyWith(name: name);

  void setType(CategoryType type) => state = state.copyWith(type: type);

  void setIcon(String icon) => state = state.copyWith(icon: icon);

  void setColor(String color) => state = state.copyWith(color: color);

  void setDescription(String description) =>
      state = state.copyWith(description: description);

  Future<Result<Category>> submit() async {
    final errors = _validate(state);
    state = state.copyWith(
      fieldErrors: errors,
      showValidationErrors: true,
      clearSubmitError: true,
    );

    if (errors.isNotEmpty) {
      return const Result.err(
        ValidationFailure(message: 'Please fix the highlighted fields'),
      );
    }

    state = state.copyWith(isSubmitting: true);
    final repository = ref.read(categoriesRepositoryProvider);
    final data = CategoryFormData(
      name: state.name,
      type: state.type,
      icon: state.icon,
      color: state.color,
      description: state.description,
    );

    try {
      final saved = state.isEditMode
          ? await repository.updateCategory(state.categoryId!, data)
          : await repository.createCategory(data);

      ref.read(categoriesListControllerProvider.notifier).upsertLocal(saved);
      state = state.copyWith(isSubmitting: false);
      return Result.ok(saved);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isSubmitting: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Future<Result<void>> delete() async {
    final id = state.categoryId;
    if (id == null) return const Result.ok(null);

    state = state.copyWith(isDeleting: true, clearSubmitError: true);
    final repository = ref.read(categoriesRepositoryProvider);

    try {
      await repository.deleteCategory(id);
      ref.read(categoriesListControllerProvider.notifier).removeLocal(id);
      state = state.copyWith(isDeleting: false);
      return const Result.ok(null);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isDeleting: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Future<Result<Category>> toggleArchive() async {
    final id = state.categoryId;
    if (id == null) return const Result.err(UnknownFailure());

    state = state.copyWith(isTogglingArchive: true, clearSubmitError: true);
    final repository = ref.read(categoriesRepositoryProvider);

    try {
      final updated = state.isArchived
          ? await repository.unarchiveCategory(id)
          : await repository.archiveCategory(id);

      ref.read(categoriesListControllerProvider.notifier).upsertLocal(updated);
      state = state.copyWith(
        isTogglingArchive: false,
        isArchived: updated.isArchived,
      );
      return Result.ok(updated);
    } catch (error) {
      final failure = mapExceptionToFailure(error);
      state = state.copyWith(isTogglingArchive: false, submitError: failure);
      return Result.err(failure);
    }
  }

  Map<String, String> _validate(CategoryFormState s) {
    final errors = <String, String>{};

    if (s.name.trim().isEmpty) {
      errors['name'] = 'Enter a category name';
    }
    if (s.icon == null || s.icon!.isEmpty) {
      errors['icon'] = 'Pick an icon';
    }

    return errors;
  }
}

final categoryFormControllerProvider = NotifierProvider.autoDispose
    .family<CategoryFormController, CategoryFormState, String?>(
      CategoryFormController.new,
    );
