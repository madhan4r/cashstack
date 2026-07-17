import 'package:flutter/material.dart';

import '../../constants/app_durations.dart';
import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';

/// Lightweight, non-interactive, auto-dismissing message that floats above
/// the current screen via [Overlay] — unlike [buildAppSnackbar], it needs
/// no [Scaffold]/[ScaffoldMessenger] and doesn't queue behind other
/// snackbars. Use for brief, low-priority confirmations ("Copied to
/// clipboard"); use the snackbar APIs when the user needs an action button
/// or the message matters enough to guarantee visibility.
class AppToast {
  const AppToast._();

  static void show(
    BuildContext context,
    String message, {
    Duration duration = AppDurations.toast,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastView(
        message: message,
        duration: duration,
        onDismissed: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastView extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastView({
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      child: FadeTransition(
        opacity: _fade,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.inverseSurface,
              borderRadius: AppRadius.radiusPill,
            ),
            child: Text(
              widget.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onInverseSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
