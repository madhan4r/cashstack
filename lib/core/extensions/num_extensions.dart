import 'package:intl/intl.dart';

/// Presentation-only currency/number formatting. Deliberately dumb (no
/// locale/currency lookups from user or account settings — that's business
/// logic for a later feature) so it's safe to use straight out of the
/// design system.
extension NumFormattingX on num {
  /// `1234.5` → `1,234.50`
  String toAmount({int decimalDigits = 2}) {
    final formatter = NumberFormat.decimalPatternDigits(
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  /// `1234.5` with [symbol] → `$1,234.50`
  String toCurrency({String symbol = '\$', int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  /// `1234.5` → `+1,234.50` / `-1,234.50`, useful for transaction amounts.
  String toSignedAmount({int decimalDigits = 2}) {
    final sign = this < 0 ? '-' : '+';
    return '$sign${abs().toAmount(decimalDigits: decimalDigits)}';
  }

  /// `0.4567` → `45.7%`
  String toPercentage({int decimalDigits = 1}) {
    return '${(this * 100).toStringAsFixed(decimalDigits)}%';
  }
}
