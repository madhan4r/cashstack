import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/feedback/app_snackbar.dart';

/// Global success/error/warning/info snackbars, callable from anywhere
/// (screens, `ref.listen` callbacks) without needing a [BuildContext] at
/// the call site — it holds the app's [scaffoldMessengerKey] instead.
/// Delegates styling to [buildAppSnackbar] so there's one definition of
/// "what a snackbar looks like" shared with any call site that already has
/// a `context` and shows one directly.
///
/// Wire it up once in `main.dart`:
/// ```dart
/// MaterialApp.router(
///   scaffoldMessengerKey: snackbarService.messengerKey,
///   ...
/// )
/// ```
class SnackbarService {
  final messengerKey = GlobalKey<ScaffoldMessengerState>();

  void showSuccess(String message) => _show(message, AppSnackbarType.success);

  void showError(String message) => _show(message, AppSnackbarType.error);

  void showWarning(String message) => _show(message, AppSnackbarType.warning);

  void showInfo(String message) => _show(message, AppSnackbarType.info);

  void _show(String message, AppSnackbarType type) {
    final context = messengerKey.currentContext;
    final messengerState = messengerKey.currentState;
    if (context == null || messengerState == null) return;

    messengerState
      ..clearSnackBars()
      ..showSnackBar(
        buildAppSnackbar(context, message: message, type: type),
      );
  }
}

final snackbarServiceProvider = Provider<SnackbarService>((ref) {
  return SnackbarService();
});
