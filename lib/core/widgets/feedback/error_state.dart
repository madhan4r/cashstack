import 'package:flutter/material.dart';

import '../../error/failure.dart';
import 'state_message_view.dart';

/// "Something went wrong" — with a retry action. Use
/// [ErrorState.fromFailure] to automatically pick a fitting icon/message
/// for a given [Failure] type.
class ErrorState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
  });

  factory ErrorState.fromFailure(Failure failure, {VoidCallback? onRetry}) {
    final icon = switch (failure) {
      NetworkFailure() => Icons.wifi_off_rounded,
      UnauthorizedFailure() => Icons.lock_outline_rounded,
      ValidationFailure() => Icons.warning_amber_rounded,
      _ => Icons.error_outline_rounded,
    };
    return ErrorState(message: failure.message, icon: icon, onRetry: onRetry);
  }

  @override
  Widget build(BuildContext context) {
    return StateMessageView(
      icon: icon,
      iconColor: Theme.of(context).colorScheme.error,
      title: message,
      actionLabel: onRetry == null ? null : 'Retry',
      onAction: onRetry,
    );
  }
}

/// Full-screen error state, for use as an entire `Scaffold.body`.
class FullScreenError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const FullScreenError({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ErrorState(message: message, onRetry: onRetry));
  }
}
