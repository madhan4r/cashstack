import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';

/// Handles taps on the "Quick Add" home-screen widget's buttons — each
/// button launches the app with a `cashstack://add?type=EXPENSE|INCOME`
/// URI (see `QuickAddWidgetProvider.kt`), which this turns into a push to
/// the Add Transaction form pre-filled with that type. The "Balance &
/// Budget" widget just opens the app plainly (no URI), so it's a no-op
/// here and lands on the normal Dashboard route.
final homeWidgetLaunchListenerProvider = Provider<void>((ref) {
  if (!Platform.isAndroid) return;

  final router = ref.watch(goRouterProvider);

  void handle(Uri? uri) {
    if (uri == null || uri.host != 'add') return;
    final type = uri.queryParameters['type'];
    if (type == null) return;
    router.push('${AppRoutes.addTransaction}?type=$type');
  }

  unawaited(HomeWidget.initiallyLaunchedFromHomeWidget().then(handle));
  final subscription = HomeWidget.widgetClicked.listen(handle);
  ref.onDispose(subscription.cancel);
});
