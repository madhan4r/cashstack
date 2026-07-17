import 'package:flutter/material.dart';

/// Wraps a non-scrolling widget (an error/loading/empty state) in a scroll
/// view with [AlwaysScrollableScrollPhysics], so a parent [RefreshIndicator]
/// still detects the pull-to-refresh gesture even when there's nothing to
/// naturally scroll.
class ScrollableSingleChild extends StatelessWidget {
  final Widget child;

  const ScrollableSingleChild({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}
