import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../models/category_type.dart';
import 'category_type_chip.dart';
import 'color_picker.dart';
import 'icon_picker.dart';

/// The Add/Edit Category form fields: name, icon picker, color picker,
/// type, and an optional description. Purely presentational — the screen
/// owns the [TextEditingController] and [CategoryFormController] state,
/// and wires them through here.
class CategoryFormBody extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  final CategoryType type;
  final ValueChanged<CategoryType> onTypeChanged;

  final String? icon;
  final ValueChanged<String> onIconChanged;

  final String? color;
  final ValueChanged<String> onColorChanged;

  final bool showValidationErrors;
  final Map<String, String> fieldErrors;

  /// Default categories can't change their type — the backend rejects it.
  final bool typeEditable;

  const CategoryFormBody({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.type,
    required this.onTypeChanged,
    required this.icon,
    required this.onIconChanged,
    required this.color,
    required this.onColorChanged,
    this.showValidationErrors = false,
    this.fieldErrors = const {},
    this.typeEditable = true,
  });

  String? _errorFor(String field) =>
      showValidationErrors ? fieldErrors[field] : null;

  @override
  Widget build(BuildContext context) {
    final accent = colorFromHex(color, fallback: context.colors.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Category Name',
          hint: 'e.g. Groceries',
          controller: nameController,
          textInputAction: TextInputAction.next,
        ),
        if (_errorFor('name') != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _errorFor('name')!,
            style: context.textStyles.bodySmall?.copyWith(color: context.colors.error),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Category Type', style: context.textStyles.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: CategoryType.values
              .map(
                (t) => CategoryTypeChip(
                  type: t,
                  selected: t == type,
                  onTap: typeEditable ? () => onTypeChanged(t) : null,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Icon', style: context.textStyles.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(categoryIconFor(icon), color: accent, size: 26),
        ),
        const SizedBox(height: AppSpacing.sm),
        IconPicker(selectedIcon: icon, accentColor: accent, onSelected: onIconChanged),
        if (_errorFor('icon') != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _errorFor('icon')!,
            style: context.textStyles.bodySmall?.copyWith(color: context.colors.error),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Color', style: context.textStyles.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        ColorPicker(selectedColor: color, onSelected: onColorChanged),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Description (optional)',
          hint: 'Add a note about this category',
          controller: descriptionController,
          maxLines: 3,
          maxLength: 500,
        ),
      ],
    );
  }
}
