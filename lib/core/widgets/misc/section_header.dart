import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../buttons/app_text_button.dart';

/// Title for a screen section, with an optional trailing action
/// ("See all", "Edit", …).
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (actionLabel != null && onAction != null)
          AppTextButton(label: actionLabel!, onPressed: onAction),
      ],
    );
  }
}
