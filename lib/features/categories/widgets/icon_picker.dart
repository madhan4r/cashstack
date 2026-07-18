import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/widgets/feedback/app_bottom_sheet.dart';
import '../../../core/widgets/inputs/search_text_field.dart';
import '../models/category_icon_groups.dart';

/// Searchable icon picker, grouped into Food/Transport/Shopping/etc. per
/// [categoryIconGroups]. Selecting a tile returns its icon key (the same
/// string the backend stores and [categoryIconFor] resolves).
class IconPicker extends StatefulWidget {
  final String? selectedIcon;
  final Color accentColor;
  final ValueChanged<String> onSelected;

  const IconPicker({
    super.key,
    required this.onSelected,
    this.selectedIcon,
    this.accentColor = Colors.blue,
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final groups = <String, List<String>>{};
    for (final entry in categoryIconGroups.entries) {
      final keys = query.isEmpty
          ? entry.value
          : entry.value
              .where((key) => key.replaceAll('-', ' ').contains(query))
              .toList();
      if (keys.isNotEmpty) groups[entry.key] = keys;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchTextField(
          hint: 'Search icons',
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: AppSpacing.md),
        Flexible(
          child: groups.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(
                    child: Text(
                      'No icons found',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final entry in groups.entries) ...[
                        Text(entry.key, style: context.textStyles.titleSmall),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: entry.value
                              .map(
                                (key) => _IconTile(
                                  iconKey: key,
                                  isSelected: key == widget.selectedIcon,
                                  accentColor: widget.accentColor,
                                  onTap: () => widget.onSelected(key),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  final String iconKey;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _IconTile({
    required this.iconKey,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: isSelected ? accentColor : accentColor.withValues(alpha: 0.12),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Icon(
          categoryIconFor(iconKey),
          color: isSelected ? _onColor(accentColor) : accentColor,
          size: 22,
        ),
      ),
    );
  }

  Color _onColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

/// Shows [IconPicker] in a bottom sheet and returns the selected icon key,
/// or `null` if dismissed without a selection.
Future<String?> showIconPickerSheet({
  required BuildContext context,
  String? selectedIcon,
  Color accentColor = Colors.blue,
}) {
  return showAppBottomSheet<String>(
    context: context,
    title: 'Choose an icon',
    builder: (context) => IconPicker(
      selectedIcon: selectedIcon,
      accentColor: accentColor,
      onSelected: (key) => Navigator.of(context).pop(key),
    ),
  );
}
