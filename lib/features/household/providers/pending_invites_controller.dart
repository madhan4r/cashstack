import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/result.dart';
import '../models/household_invite.dart';
import '../repositories/household_repository.dart';
import 'household_controller.dart';

/// Pending invites addressed to the caller's own email.
class PendingInvitesController extends AsyncNotifier<List<HouseholdInvite>> {
  @override
  Future<List<HouseholdInvite>> build() {
    return ref.watch(householdRepositoryProvider).getPendingInvites();
  }

  Future<void> refresh() async {
    final repository = ref.read(householdRepositoryProvider);
    state = await AsyncValue.guard(repository.getPendingInvites);
  }

  Future<Result<void>> respond(String inviteId, {required bool accept}) async {
    try {
      await ref
          .read(householdRepositoryProvider)
          .respondToInvite(inviteId, accept: accept);
      await refresh();
      if (accept) {
        await ref.read(householdControllerProvider.notifier).refresh();
      }
      return const Result.ok(null);
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }
}

final pendingInvitesControllerProvider =
    AsyncNotifierProvider<PendingInvitesController, List<HouseholdInvite>>(
      PendingInvitesController.new,
    );

final pendingInvitesCountProvider = Provider<int>((ref) {
  return ref.watch(pendingInvitesControllerProvider).value?.length ?? 0;
});
