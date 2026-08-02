import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../shared/models/transaction_kind.dart';
import '../../auth/providers/preferred_currency_provider.dart';
import '../models/detected_transaction.dart';
import '../models/transaction_notification_parser.dart';
import 'detected_transactions_controller.dart';
import 'smart_detection_enabled_controller.dart';

/// CashStack's own Android package — never treat our own notifications
/// (reminders, feedback confirmations, etc.) as a bank notification to
/// parse.
const _ownPackageName = 'com.example.cashstack';

/// Subscribes to bank notifications and turns matching ones into
/// [DetectedTransaction] candidates while [smartDetectionEnabledProvider]
/// is on — tears the subscription down the moment it's turned off. Kept
/// alive at the app root (see `app.dart`) purely by being watched there;
/// nothing reads its (unit) value.
final notificationDetectionListenerProvider = Provider<void>((ref) {
  final enabled = ref.watch(smartDetectionEnabledProvider);
  if (!enabled) return;

  final detectedController = ref.read(detectedTransactionsControllerProvider.notifier);

  // Candidates captured natively while the app process was dead (see
  // NativeNotificationCaptureReceiver) only ever reach Dart here — pull them
  // in now, and again every time the app comes back to the foreground.
  detectedController.drainNativeCaptures();
  final lifecycleListener = AppLifecycleListener(
    onResume: () => detectedController.drainNativeCaptures(),
  );
  ref.onDispose(lifecycleListener.dispose);

  final subscription = NotificationListenerService.notificationsStream.listen((event) {
    if (event.hasRemoved || event.packageName == _ownPackageName) return;

    final text = '${event.title} ${event.content}'.trim();
    final candidate = TransactionNotificationParser.parse(text);
    if (candidate == null) return;

    final detected = DetectedTransaction(
      id: '${event.timestamp}-${event.id}',
      amount: candidate.amount,
      type: candidate.type,
      sourceApp: event.packageName,
      rawText: text,
      detectedAt: event.humanTime,
    );

    detectedController.addDetected(detected);

    final symbol = ref.read(preferredCurrencySymbolProvider);
    ref.read(notificationServiceProvider).showNow(
      id: detected.id.hashCode,
      title: 'Transaction detected',
      body:
          '$symbol${detected.amount.toStringAsFixed(2)} '
          '${candidate.type == TransactionKind.expense ? 'debited' : 'credited'} — tap to review',
    );
  });

  ref.onDispose(subscription.cancel);
});
