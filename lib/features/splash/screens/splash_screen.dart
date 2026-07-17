import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/feedback/circular_loader.dart';
import '../../../features/auth/providers/auth_controller.dart';

/// Shown while [AuthController] checks whether a stored session is still
/// valid. The router itself decides where to go next (login vs home) once
/// that check resolves. If the check fails for a retryable reason (network
/// error), this screen offers a retry instead of the router silently
/// bouncing to Login — the session might still be valid.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoreError = ref.watch(authControllerProvider).restoreError;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 40,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'CashStack',
                style: context.textStyles.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              if (restoreError == null)
                const CircularLoader()
              else ...[
                Text(
                  restoreError,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  label: 'Retry',
                  fullWidth: false,
                  onPressed: () => ref
                      .read(authControllerProvider.notifier)
                      .retryRestoreSession(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
