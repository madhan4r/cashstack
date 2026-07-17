import 'package:flutter/material.dart';

/// Themed list row — a thin wrapper over [ListTile] so leading/trailing
/// icon sizing and text styles stay consistent everywhere a row-style list
/// is used. [TransactionTile] and similar domain-flavored rows build on
/// this instead of styling [ListTile] from scratch.
class AppListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: leading,
      title: Text(title, style: textTheme.titleSmall),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: contentPadding,
    );
  }
}
