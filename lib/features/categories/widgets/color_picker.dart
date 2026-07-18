import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

/// Grid of predefined swatches from [AppColors.categoryPalette] — no
/// custom hex input, so every chosen color still looks intentional next to
/// the rest of the app. Selecting a swatch returns its `#RRGGBB` hex.
class ColorPicker extends StatelessWidget {
  final String? selectedColor;
  final ValueChanged<String> onSelected;

  const ColorPicker({super.key, required this.onSelected, this.selectedColor});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AppColors.categoryPalette.map((color) {
        final hex = _toHex(color);
        final isSelected = hex.toLowerCase() == selectedColor?.toLowerCase();

        return InkWell(
          onTap: () => onSelected(hex),
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                  : null,
            ),
            child: isSelected
                ? Icon(Icons.check_rounded, color: _onColor(color), size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  String _toHex(Color color) {
    String channel(double value) =>
        (value * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    return '#${channel(color.r)}${channel(color.g)}${channel(color.b)}'.toUpperCase();
  }

  Color _onColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
