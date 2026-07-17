import 'package:flutter/material.dart';

import 'app_button_size.dart';
import 'button_content.dart';

/// A lower-emphasis action with a visible border, no fill. Use for
/// "Cancel" next to a primary action, or standalone secondary actions on a
/// card.
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const AppOutlinedButton({
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

    final button = OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(minimumSize: Size(0, size.height)),
      child: ButtonContent(
        label: label,
        isLoading: isLoading,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        loaderColor: Theme.of(context).colorScheme.primary,
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
