import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_controller.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/notifications/providers/notifications_controller.dart';
import 'notification_service.dart';

/// Registers this device's FCM token with the backend while the user is
/// signed in, keeps it fresh on rotation, and shows a local notification
/// for messages that arrive while the app is in the foreground (FCM only
/// auto-displays a system notification for background/terminated state).
///
/// Tolerant of Firebase not being configured yet (no
/// `google-services.json`) — every step is wrapped so a missing/incomplete
/// Firebase setup just means push notifications don't work, not that the
/// app fails to start. See `android/app/build.gradle.kts` for the matching
/// native-side guard.
final pushRegistrationProvider = Provider<void>((ref) {
  final isAuthenticated = ref.watch(authControllerProvider).isAuthenticated;
  if (!isAuthenticated) return;

  String? registeredToken;
  StreamSubscription<String>? tokenRefreshSub;
  StreamSubscription<RemoteMessage>? foregroundMessageSub;

  Future<void> setUp() async {
    try {
      // Must fully resolve before touching FirebaseMessaging.instance below
      // — that getter throws `[core/no-app]` if the default app isn't up
      // yet, which it reliably wasn't when this used to fire the two
      // `.listen()` calls synchronously ahead of this await.
      await Firebase.initializeApp();
    } catch (error) {
      debugPrint('Firebase not configured — push notifications disabled: $error');
      return;
    }

    final messaging = FirebaseMessaging.instance;

    tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) async {
      registeredToken = newToken;
      await ref.read(authRepositoryProvider).registerPushToken(newToken);
    });

    foregroundMessageSub = FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      ref
          .read(notificationServiceProvider)
          .showNow(
            id: message.hashCode,
            title: notification.title ?? 'CashStack',
            body: notification.body ?? '',
          );
      // The backend already persisted this in the notification center (see
      // PushNotificationService.sendToUser) by the time the push arrives —
      // refresh so the bell badge/list reflect it without waiting for the
      // user to happen to revisit the screen.
      ref.read(notificationsControllerProvider.notifier).refresh();
    });

    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken();
    if (token != null) {
      registeredToken = token;
      await ref.read(authRepositoryProvider).registerPushToken(token);
    }
  }

  setUp();

  ref.onDispose(() {
    tokenRefreshSub?.cancel();
    foregroundMessageSub?.cancel();
    final token = registeredToken;
    if (token != null) {
      // Best-effort — the user is signing out, so a failure here just means
      // this device keeps receiving pushes until the token naturally
      // rotates or the backend prunes it as stale.
      ref.read(authRepositoryProvider).unregisterPushToken(token);
    }
  });
});
