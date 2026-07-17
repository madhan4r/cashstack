import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../extensions/context_extensions.dart';

enum AppSnackbarType { success, error, warning, info }

/// Builds the themed [SnackBar] content shared by every snackbar in the
/// app. [SnackbarService] (see `services/snackbar_service.dart`) uses this
/// for its global, `BuildContext`-free API; call
/// [ScaffoldMessenger.showSnackBar] with it directly when you already have
/// a `context` (e.g. inside a screen's own error handling).
SnackBar buildAppSnackbar(
  BuildContext context, {
  required String message,
  AppSnackbarType type = AppSnackbarType.info,
  SnackBarAction? action,
}) {
  final semantic = context.semanticColors;
  final (icon, color) = switch (type) {
    AppSnackbarType.success => (Icons.check_circle_rounded, semantic.success),
    AppSnackbarType.error => (Icons.error_rounded, semantic.danger),
    AppSnackbarType.warning => (Icons.warning_rounded, semantic.warning),
    AppSnackbarType.info => (Icons.info_rounded, semantic.info),
  };

  return SnackBar(
    content: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
    action: action,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.radiusMd,
      side: BorderSide(color: color.withValues(alpha: 0.4)),
    ),
  );
}
