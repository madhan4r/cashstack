import '../../../shared/models/transaction_kind.dart';

/// A transaction candidate parsed out of a bank notification's text.
class ParsedTransactionCandidate {
  final double amount;
  final TransactionKind type;

  const ParsedTransactionCandidate({required this.amount, required this.type});
}

/// Parses bank debit/credit notifications (e.g. "Rs.500.00 debited from
/// A/c XX1234 to VPA merchant@ybl") into a candidate transaction.
///
/// Deliberately content-based rather than package-name-based — hardcoding
/// a list of bank app package names would silently miss any bank not on
/// the list. Requiring *both* a currency amount and an unambiguous
/// debit/credit keyword keeps false positives (promotions, OTPs, unrelated
/// notifications) low without needing to know which app sent it.
class TransactionNotificationParser {
  const TransactionNotificationParser._();

  static final _amountPattern = RegExp(
    r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  static final _debitPattern = RegExp(
    r'\b(debited|debit|spent|paid|withdrawn|purchase)\b',
    caseSensitive: false,
  );

  static final _creditPattern = RegExp(
    r'\b(credited|credit|received|deposited)\b',
    caseSensitive: false,
  );

  /// Returns `null` if [text] doesn't look like a bank debit/credit
  /// notification.
  static ParsedTransactionCandidate? parse(String text) {
    final amountMatch = _amountPattern.firstMatch(text);
    if (amountMatch == null) return null;

    final amount = double.tryParse((amountMatch.group(1) ?? '').replaceAll(',', ''));
    if (amount == null || amount <= 0) return null;

    final isDebit = _debitPattern.hasMatch(text);
    final isCredit = _creditPattern.hasMatch(text);
    // Neither matched, or both did (ambiguous) — skip rather than guess.
    if (isDebit == isCredit) return null;

    return ParsedTransactionCandidate(
      amount: amount,
      type: isDebit ? TransactionKind.expense : TransactionKind.income,
    );
  }
}
