import 'package:flutter/material.dart';

import 'app_button_size.dart';
import 'button_content.dart';

/// A secondary action button — tonal fill (soft brand-tinted background).
/// Use for the second-priority action alongside an [AppPrimaryButton]
/// (e.g. "Save as draft" next to "Publish").
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;
    final colorScheme = Theme.of(context).colorScheme;

    final button = FilledButton.tonal(
      onPressed: isDisabled ? null : onPressed,
      style: FilledButton.styleFrom(minimumSize: Size(0, size.height)),
      child: ButtonContent(
        label: label,
        isLoading: isLoading,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        loaderColor: colorScheme.onSecondaryContainer,
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
