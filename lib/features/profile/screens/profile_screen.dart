import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/buttons/app_outlined_button.dart';
import '../../../core/widgets/cards/app_list_tile.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../../services/snackbar_service.dart';
import '../../auth/providers/auth_controller.dart';
import '../widgets/edit_name_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _handleEditName(BuildContext context, WidgetRef ref, String currentName) async {
    final newName = await showEditNameSheet(context: context, currentName: currentName);
    if (newName == null || !context.mounted) return;

    final result = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(fullName: newName);
    if (!context.mounted) return;

    result.when(
      ok: (_) => ref.read(snackbarServiceProvider).showSuccess('Name updated'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: const CashStackAppBar(title: 'Profile', showBackButton: false),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Hero(
              tag: 'profile-avatar',
              child: CircleAvatar(
                radius: 36,
                backgroundColor: context.colors.primaryContainer,
                child: Icon(
                  Icons.person_outline,
                  size: 36,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
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
          AppListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: 'Edit Name',
            subtitle: user?.fullName,
            onTap: () => _handleEditName(context, ref, user?.fullName ?? ''),
          ),
          AppListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: 'Change Password',
            onTap: () => context.push(AppRoutes.changePassword),
          ),
          AppListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: 'Send Feedback',
            subtitle: 'Report a bug or share a suggestion',
            onTap: () => context.push(AppRoutes.feedback),
          ),
          const SizedBox(height: 24),
          AppOutlinedButton(
            label: 'Log out',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
