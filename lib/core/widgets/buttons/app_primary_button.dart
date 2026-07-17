import 'package:flutter/material.dart';

import 'app_button_size.dart';
import 'button_content.dart';

/// The app's primary call-to-action button — filled with the brand color.
/// Use exactly one per screen for the main action (Save, Continue, Log in).
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const AppPrimaryButton({
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

    final button = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(minimumSize: Size(0, size.height)),
      child: ButtonContent(
        label: label,
        isLoading: isLoading,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        loaderColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
