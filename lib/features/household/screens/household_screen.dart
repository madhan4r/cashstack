import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/cards/app_list_tile.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../routes/app_routes.dart';
import '../../../services/snackbar_service.dart';
import '../../auth/providers/auth_controller.dart';
import '../providers/household_controller.dart';
import '../providers/pending_invites_controller.dart';
import '../widgets/invite_member_sheet.dart';

class HouseholdScreen extends ConsumerWidget {
  const HouseholdScreen({super.key});

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave household?'),
        content: const Text(
          "You'll go back to seeing only your own accounts and transactions.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await ref.read(householdControllerProvider.notifier).leave();
    if (!context.mounted) return;
    result.when(
      ok: (_) => ref.read(snackbarServiceProvider).showSuccess("You've left the household"),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdAsync = ref.watch(householdControllerProvider);
    final pendingCount = ref.watch(pendingInvitesCountProvider);
    final myUserId = ref.watch(authControllerProvider).user?.id;

    return Scaffold(
      appBar: CashStackAppBar(
        title: 'Household',
        actions: [
          if (pendingCount > 0)
            IconButton(
              tooltip: 'Pending invites',
              icon: Badge(
                label: Text('$pendingCount'),
                child: const Icon(Icons.mail_outline_rounded),
              ),
              onPressed: () => context.push(AppRoutes.pendingInvites),
            ),
        ],
      ),
      body: householdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (household) {
          if (household == null) {
            return _EmptyState(
              onInvite: () => showInviteMemberSheet(context),
              pendingCount: pendingCount,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(household.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${household.members.length} ${household.members.length == 1 ? 'member' : 'members'} — everyone can see and edit '
                'everyone else\'s accounts and transactions.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...household.members.map(
                (member) => AppListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline_rounded)),
                  title: member.id == myUserId ? '${member.fullName} (You)' : member.fullName,
                  subtitle: member.email,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: 'Invite Another Member',
                onPressed: () => showInviteMemberSheet(context),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => _leave(context, ref),
                child: const Text('Leave Household'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onInvite;
  final int pendingCount;

  const _EmptyState({required this.onInvite, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "You're not sharing your finances with anyone yet",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Invite a partner or family member to see and manage your '
              'accounts and transactions together.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'Invite Someone',
              fullWidth: false,
              onPressed: onInvite,
            ),
          ],
        ),
      ),
    );
  }
}
