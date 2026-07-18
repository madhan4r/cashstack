import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/app_bottom_sheet.dart';
import '../models/category_selector_item.dart';
import 'category_selector.dart';

/// Shows the reusable [CategorySelector] in a bottom sheet and returns the
/// selected category id, or `null` if dismissed without a selection. The
/// caller is responsible for pre-scoping [categories] (e.g. to a single
/// Expense/Income type) — the selector itself is agnostic to that.
Future<String?> showCategorySelectorSheet({
  required BuildContext context,
  required List<CategorySelectorItem> categories,
  String? selectedCategoryId,
  String title = 'Select category',
}) {
  return showAppBottomSheet<String>(
    context: context,
    title: title,
    builder: (context) => CategorySelector(
      categories: categories,
      selectedCategoryId: selectedCategoryId,
      onSelected: (id) => Navigator.of(context).pop(id),
    ),
  );
}
