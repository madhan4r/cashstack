import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

/// Loads the dashboard summary. Using [AsyncNotifier] (rather than the
/// `Result<T>` pattern used by `auth`) is the idiomatic Riverpod fit for a
/// pure data-fetch: `AsyncValue` gives loading/error/data for free, and
/// pull-to-refresh/retry are both just `ref.refresh(dashboardControllerProvider.future)`.
class DashboardController extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() {
    return ref.watch(dashboardRepositoryProvider).getDashboard();
  }

  /// Re-fetches and updates the UI once the new data arrives, instead of
  /// flashing back to a loading state — used by pull-to-refresh.
  Future<void> refresh() async {
    final repository = ref.read(dashboardRepositoryProvider);
    final result = await AsyncValue.guard(repository.getDashboard);
    state = result;
  }
}

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardData>(
      DashboardController.new,
    );
