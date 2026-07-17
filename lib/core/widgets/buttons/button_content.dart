import 'package:flutter/material.dart';

/// Shared "label / leading icon / loading spinner" layout used by every
/// button variant, so the loading-swap behavior only lives in one place.
class ButtonContent extends StatelessWidget {
  final String label;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? loaderColor;

  const ButtonContent({
    super.key,
    required this.label,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.loaderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: loaderColor,
        ),
      );
    }

    if (leadingIcon == null && trailingIcon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 18),
        ],
      ],
    );
  }
}
