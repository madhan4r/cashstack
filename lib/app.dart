import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/biometric/app_lock_gate.dart';
import 'core/biometric/biometric_lock_controller.dart';
import 'core/constants/app_constants.dart';
import 'core/home_widget/home_widget_launch_listener.dart';
import 'core/home_widget/home_widget_sync_service.dart';
import 'core/notifications/push_registration_provider.dart';
import 'core/session/user_scoped_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/auth/providers/auth_controller.dart';
import 'features/auth/providers/auth_state.dart';
import 'features/auth/providers/preferred_currency_provider.dart';
import 'features/dashboard/providers/dashboard_controller.dart';
import 'features/notifications/providers/notifications_controller.dart';
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

    // Registers/unregisters this device's FCM token with the backend for
    // the lifetime of the signed-in session — see the provider's own doc.
    if (isAuthenticated) ref.watch(pushRegistrationProvider);

    // Keeps the "Balance & Budget" home-screen widget in sync with
    // whatever the Dashboard last successfully loaded — the widget itself
    // never fetches anything, it only ever shows what was pushed here.
    // Gated the same as the other listeners above: `ref.listen` creates
    // the provider the moment it's registered, so listening unconditionally
    // would fetch the dashboard (a live network call) before the user is
    // even signed in — including at cold start on the splash screen.
    if (isAuthenticated) {
      void syncWidget() {
        final data = ref.read(dashboardControllerProvider).value;
        if (data == null) return;
        homeWidgetSyncService.syncDashboard(
          balance: data.currentBalance,
          monthlyIncome: data.monthlyIncome,
          monthlyExpense: data.monthlyExpense,
          monthlyBudget: data.monthlyBudget,
          currencySymbol: ref.read(preferredCurrencySymbolProvider),
          unreadNotificationCount: ref.read(unreadNotificationCountProvider),
        );
      }

      ref.listen(dashboardControllerProvider, (previous, next) {
        if (next.value != null) syncWidget();
      });
      // Also re-syncs on its own — e.g. marking a notification read should
      // clear the widget's badge without waiting for the next dashboard
      // refresh.
      ref.listen(unreadNotificationCountProvider, (previous, next) {
        syncWidget();
      });
    }

    // Every screen's data providers cache their last fetch indefinitely
    // (they're not autoDispose) so the app doesn't refetch on every
    // navigation. That means a login/logout that changes *who* is signed
    // in must explicitly blow those caches away, or the next screen briefly
    // renders the previous user's accounts/transactions/etc.
    //
    // Gated on `previous?.user?.id != null` — without it, this also fires
    // on the very first auth resolution at cold start (previous.user is
    // null while session-restore is still in flight, then becomes the
    // restored user), which isn't a user switch at all. Left ungated, that
    // false-positive called `setUnlocked(false)` right after the user's
    // biometric unlock succeeded, re-locking the app and triggering a
    // second fingerprint prompt on every single cold start.
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.user?.id != null && previous?.user?.id != next.user?.id) {
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
        return AppLockGate(child: child);
      },
    );
  }
}
