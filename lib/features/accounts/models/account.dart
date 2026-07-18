import 'package:equatable/equatable.dart';

import 'account_type.dart';

/// A single account, as returned by `GET /accounts` and `GET /accounts/:id`.
/// Mirrors the backend's `AccountResponseDto`. `balance` is the computed
/// opening-balance-plus-ledger figure the backend attaches on those two
/// endpoints only — see [Account.fromJson]'s fallback for the create/
/// update/archive/unarchive responses that don't include it.
class Account extends Equatable {
  final String id;
  final String name;
  final AccountType type;
  final double openingBalance;
  final double balance;
  final String currency;
  final String? color;
  final String? icon;
  final String? description;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.openingBalance,
    required this.balance,
    required this.currency,
    this.color,
    this.icon,
    this.description,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    final openingBalance = (json['openingBalance'] as num).toDouble();
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountType.fromJson(json['type'] as String),
      openingBalance: openingBalance,
      balance: (json['balance'] as num?)?.toDouble() ?? openingBalance,
      currency: json['currency'] as String,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Account copyWith({double? balance, bool? isArchived}) {
    return Account(
      id: id,
      name: name,
      type: type,
      openingBalance: openingBalance,
      balance: balance ?? this.balance,
      currency: currency,
      color: color,
      icon: icon,
      description: description,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    openingBalance,
    balance,
    currency,
    color,
    icon,
    description,
    isArchived,
    createdAt,
    updatedAt,
  ];
}
