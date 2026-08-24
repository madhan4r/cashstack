import 'account_type.dart';

/// The create/update payload for `POST /accounts` and `PATCH /accounts/:id`.
class AccountFormData {
  final String name;
  final AccountType type;
  final String currency;
  final double openingBalance;
  final String? description;
  final double? lowBalanceThreshold;

  const AccountFormData({
    required this.name,
    required this.type,
    required this.currency,
    required this.openingBalance,
    this.description,
    this.lowBalanceThreshold,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'type': type.toJson(),
      'currency': currency,
      'openingBalance': openingBalance,
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      'lowBalanceThreshold': lowBalanceThreshold,
    };
  }
}
