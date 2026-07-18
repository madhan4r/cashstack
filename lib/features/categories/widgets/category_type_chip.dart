import 'package:flutter/material.dart';

import '../../../core/widgets/cards/category_chip.dart';
import '../models/category_type.dart';

/// Selectable pill for a [CategoryType] — thin wrapper around the shared
/// [CategoryChip].
class CategoryTypeChip extends StatelessWidget {
  final CategoryType type;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryTypeChip({
    super.key,
    required this.type,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CategoryChip(
      label: type.label,
      icon: type == CategoryType.income
          ? Icons.arrow_downward_rounded
          : Icons.arrow_upward_rounded,
      selected: selected,
      onTap: onTap,
    );
  }
}
