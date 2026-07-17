import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../features/auth/providers/auth_controller.dart';

/// Placeholder home screen. Business content (balances, transactions,
/// budgets, …) is intentionally out of scope for this foundation.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: const CashStackAppBar(title: 'CashStack', showBackButton: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.dashboard_customize_outlined,
                size: 48,
                color: context.colors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                user == null
                    ? 'Welcome to CashStack'
                    : 'Welcome back, ${user.fullName.split(' ').first}',
                style: context.textStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your dashboard will appear here soon.',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
