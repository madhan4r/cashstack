import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/biometric/app_lock_gate.dart';
import 'core/biometric/biometric_lock_controller.dart';
import 'core/constants/app_constants.dart';
import 'core/session/screenshot_capture.dart';
import 'core/session/user_scoped_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/widgets/misc/feedback_launcher.dart';
import 'features/auth/providers/auth_controller.dart';
import 'features/auth/providers/auth_state.dart';
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
        final isAuthenticated = ref.watch(authControllerProvider).isAuthenticated;
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
