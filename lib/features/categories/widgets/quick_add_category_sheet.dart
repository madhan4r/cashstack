import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/feedback/app_bottom_sheet.dart';
import '../models/category.dart';
import '../models/category_type.dart';
import '../providers/category_form_controller.dart';
import 'category_form.dart';

/// Lets the user create a category without leaving whatever screen opened
/// it (see [CategorySelector.onCreateNew]) — the same Add-Category form as
/// the full screen, just in a sheet. Returns the created [Category], or
/// `null` if dismissed without saving.
Future<Category?> showQuickAddCategorySheet({
  required BuildContext context,
  required CategoryType type,
}) {
  return showAppBottomSheet<Category>(
    context: context,
    title: 'Add Category',
    builder: (context) => _QuickAddCategoryForm(type: type),
  );
}

class _QuickAddCategoryForm extends ConsumerStatefulWidget {
  final CategoryType type;

  const _QuickAddCategoryForm({required this.type});

  @override
  ConsumerState<_QuickAddCategoryForm> createState() => _QuickAddCategoryFormState();
}

class _QuickAddCategoryFormState extends ConsumerState<_QuickAddCategoryForm> {
  late final _nameController = TextEditingController();
  late final _descriptionController = TextEditingController();
  bool _typeSet = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = ref.read(categoryFormControllerProvider(null).notifier);
    controller.setName(_nameController.text);
    controller.setDescription(_descriptionController.text);
    final result = await controller.submit();
    if (!mounted) return;

    result.when(
      ok: (category) => Navigator.of(context).pop(category),
      err: (_) {}, // Surfaced inline via fieldErrors below.
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryFormControllerProvider(null));
    final controller = ref.read(categoryFormControllerProvider(null).notifier);

    // The family provider always starts in Expense mode — nudge it to the
    // transaction's actual type once, right after the first build.
    if (!_typeSet) {
      _typeSet = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.setType(widget.type));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CategoryFormBody(
              nameController: _nameController,
              descriptionController: _descriptionController,
              type: state.type,
              onTypeChanged: controller.setType,
              icon: state.icon,
              onIconChanged: controller.setIcon,
              color: state.color,
              onColorChanged: controller.setColor,
              showValidationErrors: state.showValidationErrors,
              fieldErrors: state.fieldErrors,
              // Fixed to whatever type the transaction form needs — a
              // category of the other type wouldn't be selectable there
              // anyway once this sheet closes.
              typeEditable: false,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'Add Category',
              isLoading: state.isSubmitting,
              onPressed: state.isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
