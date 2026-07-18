import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/misc/scrollable_single_child.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../services/snackbar_service.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Single reusable Add/Edit Category screen — `categoryId == null` is Add
/// mode, otherwise Edit mode (pre-filled, with archive/delete actions).
class CategoryFormScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const CategoryFormScreen({super.key, this.categoryId});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  late final _nameController = TextEditingController();
  late final _descriptionController = TextEditingController();
  bool _seededFromState = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _seedControllers(CategoryFormState state) {
    if (_seededFromState) return;
    _nameController.text = state.name;
    _descriptionController.text = state.description;
    _seededFromState = true;
  }

  Future<void> _handleSave(bool isEditMode) async {
    final controller = ref.read(categoryFormControllerProvider(widget.categoryId).notifier);
    controller.setName(_nameController.text);
    controller.setDescription(_descriptionController.text);
    final result = await controller.submit();
    if (!mounted) return;

    result.when(
      ok: (category) {
        ref
            .read(snackbarServiceProvider)
            .showSuccess(isEditMode ? 'Category updated' : 'Category created');
        context.pop();
      },
      err: (failure) {
        if (failure is! ValidationFailure) {
          ref.read(snackbarServiceProvider).showError(failure.message);
        }
      },
    );
  }

  Future<void> _handleDelete(String categoryName) async {
    final confirmed = await showDeleteCategoryConfirmation(
      context: context,
      categoryName: categoryName,
    );
    if (confirmed != true || !mounted) return;

    final controller = ref.read(categoryFormControllerProvider(widget.categoryId).notifier);
    final result = await controller.delete();
    if (!mounted) return;

    result.when(
      ok: (_) {
        ref.read(snackbarServiceProvider).showSuccess('Category deleted');
        context.pop();
      },
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  Future<void> _handleToggleArchive(
    String categoryName,
    bool isArchived,
    bool hasTransactions,
  ) async {
    final confirmed = await showArchiveCategoryConfirmation(
      context: context,
      categoryName: categoryName,
      isCurrentlyArchived: isArchived,
      hasTransactions: hasTransactions,
    );
    if (confirmed != true || !mounted) return;

    final controller = ref.read(categoryFormControllerProvider(widget.categoryId).notifier);
    final result = await controller.toggleArchive();
    if (!mounted) return;

    result.when(
      ok: (category) => ref
          .read(snackbarServiceProvider)
          .showSuccess(category.isArchived ? 'Category archived' : 'Category unarchived'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryFormControllerProvider(widget.categoryId));

    ref.listen(categoryFormControllerProvider(widget.categoryId), (previous, next) {
      if (!next.isLoadingInitial && next.loadError == null) {
        _seedControllers(next);
      }
    });

    return Scaffold(
      appBar: CashStackAppBar(
        title: state.isEditMode ? 'Edit Category' : 'Add Category',
        actions: [
          if (state.isEditMode &&
              !state.isLoadingInitial &&
              state.loadError == null &&
              state.canDelete)
            IconButton(
              onPressed: () => _handleDelete(_nameController.text),
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete category',
            ),
        ],
      ),
      body: state.isLoadingInitial
          ? const Center(child: CircularProgressIndicator())
          : state.loadError != null
          ? ScrollableSingleChild(
              child: ErrorState.fromFailure(
                state.loadError!,
                onRetry: () => ref
                    .read(categoryFormControllerProvider(widget.categoryId).notifier)
                    .retryLoad(),
              ),
            )
          : _FormContent(
              categoryId: widget.categoryId,
              state: state,
              nameController: _nameController,
              descriptionController: _descriptionController,
              onSave: () => _handleSave(state.isEditMode),
              onToggleArchive: () => _handleToggleArchive(
                _nameController.text,
                state.isArchived,
                state.transactionCount > 0,
              ),
            ),
    );
  }
}

class _FormContent extends ConsumerWidget {
  final String? categoryId;
  final CategoryFormState state;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final VoidCallback onSave;
  final VoidCallback onToggleArchive;

  const _FormContent({
    required this.categoryId,
    required this.state,
    required this.nameController,
    required this.descriptionController,
    required this.onSave,
    required this.onToggleArchive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(categoryFormControllerProvider(categoryId).notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.isEditMode && !state.isEditable) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'This is a default category — you can archive it, but its name, '
                  'type, icon, and color can\'t be changed.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            IgnorePointer(
              ignoring: state.isEditMode && !state.isEditable,
              child: Opacity(
                opacity: state.isEditMode && !state.isEditable ? 0.6 : 1,
                child: CategoryFormBody(
                  nameController: nameController,
                  descriptionController: descriptionController,
                  type: state.type,
                  onTypeChanged: controller.setType,
                  icon: state.icon,
                  onIconChanged: controller.setIcon,
                  color: state.color,
                  onColorChanged: controller.setColor,
                  showValidationErrors: state.showValidationErrors,
                  fieldErrors: state.fieldErrors,
                  typeEditable: state.isEditable,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (state.isEditable)
              AppPrimaryButton(
                label: state.isEditMode ? 'Save Changes' : 'Add Category',
                isLoading: state.isSubmitting,
                onPressed: state.isSubmitting ? null : onSave,
              ),
            if (state.isEditMode) ...[
              const SizedBox(height: AppSpacing.sm),
              AppOutlinedButton(
                label: state.isArchived ? 'Unarchive Category' : 'Archive Category',
                isLoading: state.isTogglingArchive,
                onPressed: state.isTogglingArchive ? null : onToggleArchive,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
