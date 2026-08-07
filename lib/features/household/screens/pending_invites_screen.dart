import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/navigation/app_bar.dart';
import '../../../services/snackbar_service.dart';
import '../models/household_invite.dart';
import '../providers/pending_invites_controller.dart';

class PendingInvitesScreen extends ConsumerWidget {
  const PendingInvitesScreen({super.key});

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    HouseholdInvite invite, {
    required bool accept,
  }) async {
    final result = await ref
        .read(pendingInvitesControllerProvider.notifier)
        .respond(invite.id, accept: accept);
    if (!context.mounted) return;
    result.when(
      ok: (_) => ref
          .read(snackbarServiceProvider)
          .showSuccess(accept ? "You've joined ${invite.householdName}" : 'Invite declined'),
      err: (failure) => ref.read(snackbarServiceProvider).showError(failure.message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitesAsync = ref.watch(pendingInvitesControllerProvider);

    return Scaffold(
      appBar: const CashStackAppBar(title: 'Pending Invites'),
      body: invitesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              error is Failure ? error.message : error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (invites) {
          if (invites.isEmpty) {
            return const Center(child: Text('No pending invites'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: invites.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final invite = invites[index];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.householdName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Invited by ${invite.invitedByName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _respond(context, ref, invite, accept: false),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                _respond(context, ref, invite, accept: true),
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
