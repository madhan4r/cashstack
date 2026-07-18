import 'package:equatable/equatable.dart';

/// Minimal account reference used to enrich transaction rows (name) and
/// to populate the account filter/selector pickers. Mirrors the backend's
/// `AccountResponseDto`, trimmed to what the Transactions feature needs.
class AccountRef extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final String currency;
  final double balance;
  final bool isArchived;

  const AccountRef({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.currency,
    required this.balance,
    required this.isArchived,
  });

  factory AccountRef.fromJson(Map<String, dynamic> json) {
    return AccountRef(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      currency: json['currency'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, color, currency, balance, isArchived];
}
