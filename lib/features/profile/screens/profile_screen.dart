import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../features/auth/providers/auth_controller.dart';

/// Placeholder profile screen. Also doubles as the easiest place to
/// exercise the logout flow end-to-end while the rest of the app is built.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: const CashStackAppBar(title: 'Profile', showBackButton: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: context.colors.primaryContainer,
              child: Icon(
                Icons.person_outline,
                size: 36,
                color: context.colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? '—',
              style: context.textStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              user?.email ?? '',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppOutlinedButton(
              label: 'Log out',
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}
