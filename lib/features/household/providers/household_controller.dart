import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/result.dart';
import '../models/household.dart';
import '../repositories/household_repository.dart';

/// The caller's current household, or `null` if they're not in one.
class HouseholdController extends AsyncNotifier<Household?> {
  @override
  Future<Household?> build() {
    return ref.watch(householdRepositoryProvider).getMyHousehold();
  }

  Future<void> refresh() async {
    final repository = ref.read(householdRepositoryProvider);
    state = await AsyncValue.guard(repository.getMyHousehold);
  }

  Future<Result<void>> invite(String email) async {
    try {
      await ref.read(householdRepositoryProvider).inviteMember(email);
      await refresh();
      return const Result.ok(null);
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }

  Future<Result<void>> leave() async {
    try {
      await ref.read(householdRepositoryProvider).leaveHousehold();
      await refresh();
      return const Result.ok(null);
    } catch (error) {
      return Result.err(mapExceptionToFailure(error));
    }
  }
}

final householdControllerProvider =
    AsyncNotifierProvider<HouseholdController, Household?>(
      HouseholdController.new,
    );
