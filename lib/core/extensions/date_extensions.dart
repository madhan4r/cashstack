import 'package:intl/intl.dart';

/// Presentation-only date formatting for lists, tiles, and headers.
extension DateFormattingX on DateTime {
  /// `Jan 15, 2024`
  String toMediumDate() => DateFormat.yMMMd().format(this);

  /// `15 Jan`
  String toShortDate() => DateFormat('d MMM').format(this);

  /// `January 2024`
  String toMonthYear() => DateFormat.yMMMM().format(this);

  /// `2:30 PM`
  String toTime() => DateFormat.jm().format(this);

  /// `Today`, `Yesterday`, or [toMediumDate].
  String toRelativeLabel({DateTime? now}) {
    final today = now ?? DateTime.now();
    final self = DateTime(year, month, day);
    final reference = DateTime(today.year, today.month, today.day);
    final difference = reference.difference(self).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return toMediumDate();
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
