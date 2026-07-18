import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recurrence_frequency.dart';
import '../models/recurring_filter.dart';
import '../models/recurring_sort_option.dart';
import '../models/recurring_status.dart';

/// The active status/frequency filter + sort for the Recurring list.
class RecurringFilterController extends Notifier<RecurringFilter> {
  @override
  RecurringFilter build() => const RecurringFilter();

  void setStatus(RecurringStatus? status) {
    state = state.copyWith(status: status, clearStatus: status == null);
  }

  void setFrequency(RecurrenceFrequency? frequency) {
    state = state.copyWith(frequency: frequency, clearFrequency: frequency == null);
  }

  void setSort(RecurringSortOption sort) {
    state = state.copyWith(sort: sort);
  }
}

final recurringFilterProvider =
    NotifierProvider<RecurringFilterController, RecurringFilter>(
      RecurringFilterController.new,
    );
