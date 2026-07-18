import '../../../shared/models/transaction_kind.dart';
import 'payment_method.dart';

/// The Add/Edit Transaction form's field values, serialized to match the
/// backend's `CreateTransactionDto` / `UpdateTransactionDto` shape. Only
/// the fields relevant to [type] are included — e.g. a TRANSFER never
/// sends `accountId`/`categoryId`, matching the backend's own
/// per-type validation.
class TransactionFormData {
  final TransactionKind type;
  final double amount;
  final String? accountId;
  final String? categoryId;
  final String? fromAccountId;
  final String? toAccountId;
  final String? notes;
  final PaymentMethod? paymentMethod;
  final DateTime transactionDate;
  final List<String> tags;

  const TransactionFormData({
    required this.type,
    required this.amount,
    this.accountId,
    this.categoryId,
    this.fromAccountId,
    this.toAccountId,
    this.notes,
    this.paymentMethod,
    required this.transactionDate,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    final isTransfer = type == TransactionKind.transfer;

    return {
      'amount': amount,
      'type': type.toJson(),
      if (!isTransfer && accountId != null) 'accountId': accountId,
      if (!isTransfer && categoryId != null) 'categoryId': categoryId,
      if (isTransfer && fromAccountId != null) 'fromAccountId': fromAccountId,
      if (isTransfer && toAccountId != null) 'toAccountId': toAccountId,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.toJson(),
      'transactionDate': transactionDate.toUtc().toIso8601String(),
      if (tags.isNotEmpty) 'tags': tags,
    };
  }
}
