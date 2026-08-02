import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _channelId = 'recurring_reminders';
const _channelName = 'Recurring transaction reminders';
const _channelDescription =
    'Reminders for upcoming bills, subscriptions, and other recurring transactions';

const _detectedChannelId = 'detected_transactions';
const _detectedChannelName = 'Detected transactions';
const _detectedChannelDescription =
    'Prompts to review a transaction detected from a bank notification';

/// Thin wrapper around [FlutterLocalNotificationsPlugin] scoped to exactly
/// what this app needs: reminders for recurring-transaction due dates.
/// Nothing outside this file should touch the plugin directly.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  NotificationService(this._plugin);

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // Deliberately not resolving the device's named IANA zone (that needs
    // a native plugin, e.g. flutter_timezone — which currently drags in a
    // Kotlin-Gradle-Plugin warning). `scheduleReminder` instead converts
    // the wall-clock reminder time with Dart's own OS-backed `.toUtc()`
    // (correct for any offset, including non-whole-hour ones like IST's
    // +5:30) and schedules it against the always-available `tz.UTC`
    // location, so no zone lookup is needed here at all.

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _initialized = true;
  }

  /// Requests OS notification permission (Android 13+, iOS). Returns
  /// whether permission was granted.
  Future<bool> requestPermission() async {
    await _ensureInitialized();

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Schedules (or replaces) a single reminder. [id] should be stable per
  /// recurring transaction so re-scheduling naturally overwrites the
  /// previous one instead of stacking duplicates.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _ensureInitialized();
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate.toUtc(), tz.UTC),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Shows a notification immediately (as opposed to [scheduleReminder]'s
  /// future-dated ones) — used to prompt reviewing a just-detected
  /// transaction.
  Future<void> showNow({required int id, required String title, required String body}) async {
    await _ensureInitialized();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _detectedChannelId,
          _detectedChannelName,
          channelDescription: _detectedChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _ensureInitialized();
    await _plugin.cancelAll();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FlutterLocalNotificationsPlugin());
});
