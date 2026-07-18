import '../../../shared/models/transaction_kind.dart';
import 'recurrence_frequency.dart';
import 'reminder_option.dart';

/// The create/update payload for `POST /recurring-transactions` and
/// `PATCH /recurring-transactions/:id`.
class RecurringFormData {
  final String name;
  final TransactionKind type;
  final double amount;
  final String categoryId;
  final String accountId;
  final String? notes;
  final RecurrenceFrequency frequency;
  final int? customIntervalDays;
  final DateTime startDate;
  final DateTime? endDate;
  final ReminderOption reminder;
  final bool autoGenerate;

  const RecurringFormData({
    required this.name,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    this.notes,
    required this.frequency,
    this.customIntervalDays,
    required this.startDate,
    this.endDate,
    required this.reminder,
    required this.autoGenerate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'type': type.toJson(),
      'amount': amount,
      'categoryId': categoryId,
      'accountId': accountId,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      'frequency': frequency.toJson(),
      if (frequency == RecurrenceFrequency.custom && customIntervalDays != null)
        'customIntervalDays': customIntervalDays,
      'startDate': startDate.toUtc().toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toUtc().toIso8601String(),
      'reminder': reminder.toJson(),
      'autoGenerate': autoGenerate,
    };
  }
}
