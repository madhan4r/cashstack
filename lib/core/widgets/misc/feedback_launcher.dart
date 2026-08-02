import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/screenshot_capture.dart';
import '../../../routes/app_router.dart';
import '../../../routes/app_routes.dart';

/// Small floating affordance, present on every authenticated screen (see
/// `app.dart`), that screenshots exactly what's currently on screen and
/// opens the Feedback form with it attached.
class FeedbackLauncher extends ConsumerStatefulWidget {
  final GlobalKey boundaryKey;

  const FeedbackLauncher({super.key, required this.boundaryKey});

  @override
  ConsumerState<FeedbackLauncher> createState() => _FeedbackLauncherState();
}

class _FeedbackLauncherState extends ConsumerState<FeedbackLauncher> {
  bool _isCapturing = false;

  Future<void> _handleTap() async {
    setState(() => _isCapturing = true);
    final bytes = await captureScreenshot(widget.boundaryKey);
    if (!mounted) return;
    setState(() => _isCapturing = false);

    ref.read(pendingFeedbackScreenshotProvider.notifier).set(bytes);
    if (!mounted) return;
    // This widget is a sibling of the Router in the Stack built by
    // MaterialApp.router's `builder` (see app.dart) — not a descendant of
    // it — so its own BuildContext has no GoRouter ancestor. Push through
    // the router instance directly instead of `context.push`.
    ref.read(goRouterProvider).push(AppRoutes.feedback);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Material(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _isCapturing ? null : _handleTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _isCapturing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.feedback_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
