import 'package:flutter/material.dart';

import 'state_message_view.dart';

/// "There's nothing here yet, but there could be" — e.g. no transactions
/// created yet. Distinct from [NoDataWidget] (filtered results) and
/// [ErrorState] (something went wrong).
class EmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return StateMessageView(
      icon: icon,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
