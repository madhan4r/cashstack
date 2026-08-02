import 'package:flutter/services.dart';

/// Bridges to `NativeCaptureStore` on the Android side (see
/// `NativeNotificationCaptureReceiver`'s doc) — candidates captured while the
/// app process was dead, queued natively, waiting to be drained into
/// [DetectedTransactionsController].
class NativeCaptureChannel {
  static const _channel = MethodChannel('cashstack/native_capture');

  const NativeCaptureChannel();

  /// Returns the raw JSON strings queued since the last drain (each one
  /// shaped like `DetectedTransaction.toJson()`), clearing the native queue.
  /// Android-only; returns an empty list on any other platform or failure.
  Future<List<String>> drainPendingCaptures() async {
    try {
      final result = await _channel.invokeListMethod<String>('drainPendingCaptures');
      return result ?? const [];
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }
}

const nativeCaptureChannel = NativeCaptureChannel();
