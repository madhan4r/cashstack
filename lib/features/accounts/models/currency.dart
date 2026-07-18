/// The backend stores currency as a free-text ISO 4217 code with no
/// canonical list of its own (`@Length(3,3)` is the only validation) — this
/// is the client-side list offered in the currency picker, plus a symbol
/// lookup used anywhere a balance is displayed.
class CurrencyOption {
  final String code;
  final String name;
  final String symbol;

  const CurrencyOption({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

const supportedCurrencies = <CurrencyOption>[
  CurrencyOption(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  CurrencyOption(code: 'USD', name: 'US Dollar', symbol: '\$'),
  CurrencyOption(code: 'EUR', name: 'Euro', symbol: '€'),
  CurrencyOption(code: 'GBP', name: 'British Pound', symbol: '£'),
  CurrencyOption(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  CurrencyOption(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
  CurrencyOption(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
  CurrencyOption(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
  CurrencyOption(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ'),
];

/// Symbol for a currency [code] (e.g. `INR` → `₹`); falls back to the code
/// itself for anything outside [supportedCurrencies] — an account created
/// with an unlisted code (or via a future API client) should never render
/// blank.
String currencySymbolFor(String code) {
  for (final currency in supportedCurrencies) {
    if (currency.code == code) return currency.symbol;
  }
  return code;
}
