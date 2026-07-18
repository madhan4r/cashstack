import 'package:equatable/equatable.dart';

import 'recurrence_frequency.dart';
import 'recurring_sort_option.dart';
import 'recurring_status.dart';

/// Client-side status/frequency filter + sort for the Recurring list.
class RecurringFilter extends Equatable {
  final RecurringStatus? status;
  final RecurrenceFrequency? frequency;
  final RecurringSortOption sort;

  const RecurringFilter({this.status, this.frequency, this.sort = RecurringSortOption.nextDue});

  RecurringFilter copyWith({
    RecurringStatus? status,
    bool clearStatus = false,
    RecurrenceFrequency? frequency,
    bool clearFrequency = false,
    RecurringSortOption? sort,
  }) {
    return RecurringFilter(
      status: clearStatus ? null : (status ?? this.status),
      frequency: clearFrequency ? null : (frequency ?? this.frequency),
      sort: sort ?? this.sort,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      if (status != null) 'status': status!.toJson(),
      if (frequency != null) 'frequency': frequency!.toJson(),
      'sort': sort.queryValue,
    };
  }

  @override
  List<Object?> get props => [status, frequency, sort];
}
