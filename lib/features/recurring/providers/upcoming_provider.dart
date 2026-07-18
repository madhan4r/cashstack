import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/upcoming_occurrence.dart';
import '../repositories/recurring_repository.dart';

/// Upcoming scheduled transactions preview, within [days] from today.
final upcomingOccurrencesProvider = FutureProvider.autoDispose
    .family<List<UpcomingOccurrence>, int>((ref, days) {
  final repository = ref.watch(recurringRepositoryProvider);
  return repository.getUpcoming(days: days);
});
