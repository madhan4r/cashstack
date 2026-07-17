import 'package:flutter/material.dart';

import 'button_content.dart';

/// The lowest-emphasis action — no fill, no border. Use for inline links
/// ("Forgot password?", "See all") and tertiary dialog actions.
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      child: ButtonContent(
        label: label,
        isLoading: isLoading,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        loaderColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
