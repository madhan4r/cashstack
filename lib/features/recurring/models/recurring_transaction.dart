import 'package:equatable/equatable.dart';

import '../../../shared/models/transaction_kind.dart';
import 'recurrence_frequency.dart';
import 'recurring_status.dart';
import 'reminder_option.dart';

/// Mirrors the backend's `RecurringResponseDto`. `type` is always income or
/// expense — the backend rejects TRANSFER for recurring schedules.
class RecurringTransaction extends Equatable {
  final String id;
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
  final RecurringStatus status;
  final DateTime nextDueDate;
  final DateTime? lastGeneratedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringTransaction({
    required this.id,
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
    required this.status,
    required this.nextDueDate,
    this.lastGeneratedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'] as String,
      name: json['name'] as String,
      type: TransactionKind.fromJson(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      accountId: json['accountId'] as String,
      notes: json['notes'] as String?,
      frequency: RecurrenceFrequency.fromJson(json['frequency'] as String),
      customIntervalDays: json['customIntervalDays'] as int?,
      startDate: DateTime.parse(json['startDate'] as String).toLocal(),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String).toLocal(),
      reminder: ReminderOption.fromJson(json['reminder'] as String),
      autoGenerate: json['autoGenerate'] as bool? ?? true,
      status: RecurringStatus.fromJson(json['status'] as String),
      nextDueDate: DateTime.parse(json['nextDueDate'] as String).toLocal(),
      lastGeneratedDate: json['lastGeneratedDate'] == null
          ? null
          : DateTime.parse(json['lastGeneratedDate'] as String).toLocal(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    amount,
    categoryId,
    accountId,
    notes,
    frequency,
    customIntervalDays,
    startDate,
    endDate,
    reminder,
    autoGenerate,
    status,
    nextDueDate,
    lastGeneratedDate,
    createdAt,
    updatedAt,
  ];
}
