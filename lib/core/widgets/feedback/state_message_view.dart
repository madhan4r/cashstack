import 'package:flutter/material.dart';

import '../buttons/app_text_button.dart';

/// Shared "icon + title + description + optional action" layout that
/// [EmptyState], [ErrorState], and [NoDataWidget] are all built from, so
/// there's exactly one place that lays out an illustration-style state
/// screen.
class StateMessageView extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StateMessageView({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (iconColor ?? theme.colorScheme.primary).withValues(
                  alpha: 0.1,
                ),
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor ?? theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppTextButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
