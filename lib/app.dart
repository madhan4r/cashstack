import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/biometric/app_lock_gate.dart';
import 'core/biometric/biometric_lock_controller.dart';
import 'core/constants/app_constants.dart';
import 'core/home_widget/home_widget_launch_listener.dart';
import 'core/home_widget/home_widget_sync_service.dart';
import 'core/session/screenshot_capture.dart';
import 'core/session/user_scoped_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/widgets/misc/feedback_launcher.dart';
import 'features/auth/providers/auth_controller.dart';
import 'features/auth/providers/auth_state.dart';
import 'features/auth/providers/preferred_currency_provider.dart';
import 'features/dashboard/providers/dashboard_controller.dart';
import 'features/transaction_detection/providers/notification_detection_listener.dart';
import 'routes/app_router.dart';
import 'services/snackbar_service.dart';

class CashStackApp extends ConsumerWidget {
  const CashStackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final snackbarService = ref.watch(snackbarServiceProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final boundaryKey = ref.watch(screenshotBoundaryKeyProvider);
    final isAuthenticated = ref.watch(authControllerProvider).isAuthenticated;

    // Keeps the bank-notification subscription alive (see the provider's
    // own doc) for as long as the user is signed in and has Smart
    // Transaction Detection turned on — a signed-out session shouldn't be
    // suggesting transactions for anyone to confirm.
    if (isAuthenticated) ref.watch(notificationDetectionListenerProvider);

    // Same lifecycle reasoning as the notification-detection listener
    // above — only meaningful (and only registers platform channels) for
    // a signed-in session on Android.
    if (isAuthenticated) ref.watch(homeWidgetLaunchListenerProvider);

    // Keeps the "Balance & Budget" home-screen widget in sync with
    // whatever the Dashboard last successfully loaded — the widget itself
    // never fetches anything, it only ever shows what was pushed here.
    // Gated the same as the other listeners above: `ref.listen` creates
    // the provider the moment it's registered, so listening unconditionally
    // would fetch the dashboard (a live network call) before the user is
    // even signed in — including at cold start on the splash screen.
    if (isAuthenticated) {
      ref.listen(dashboardControllerProvider, (previous, next) {
        final data = next.value;
        if (data == null) return;
        homeWidgetSyncService.syncDashboard(
          balance: data.currentBalance,
          monthlyIncome: data.monthlyIncome,
          monthlyExpense: data.monthlyExpense,
          monthlyBudget: data.monthlyBudget,
          currencySymbol: ref.read(preferredCurrencySymbolProvider),
        );
      });
    }

    // Every screen's data providers cache their last fetch indefinitely
    // (they're not autoDispose) so the app doesn't refetch on every
    // navigation. That means a login/logout that changes *who* is signed
    // in must explicitly blow those caches away, or the next screen briefly
    // renders the previous user's accounts/transactions/etc.
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        resetUserScopedProviders(ref);
        ref.read(appUnlockedProvider.notifier).setUnlocked(false);
      }
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      scaffoldMessengerKey: snackbarService.messengerKey,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return AppLockGate(
          child: Stack(
            children: [
              RepaintBoundary(key: boundaryKey, child: child),
              if (isAuthenticated)
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: FeedbackLauncher(boundaryKey: boundaryKey),
                ),
            ],
          ),
        );
      },
    );
  }
}
