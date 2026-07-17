import 'package:flutter/material.dart';

import 'state_message_view.dart';

/// "There is data, but nothing matches the current view" — e.g. a filtered
/// or searched list with zero results. Distinct from [EmptyState] (nothing
/// has ever been created) so the copy/icon can reflect "try a different
/// filter" rather than "get started".
class NoDataWidget extends StatelessWidget {
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const NoDataWidget({
    super.key,
    this.title = 'No results found',
    this.description = 'Try adjusting your filters or search terms.',
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return StateMessageView(
      icon: Icons.filter_alt_off_outlined,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
