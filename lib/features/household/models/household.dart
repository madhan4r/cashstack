import 'package:equatable/equatable.dart';

/// Per-viewer preference for how household data is shown — not a
/// household-wide setting, just what the signed-in user currently sees.
enum HouseholdViewMode {
  /// Every member's accounts/transactions/etc. pooled together.
  combined,

  /// Only the signed-in user's own data, even while still a member.
  separate;

  factory HouseholdViewMode.fromJson(String value) {
    return value == 'SEPARATE'
        ? HouseholdViewMode.separate
        : HouseholdViewMode.combined;
  }

  String toJson() => switch (this) {
    HouseholdViewMode.combined => 'COMBINED',
    HouseholdViewMode.separate => 'SEPARATE',
  };
}

class HouseholdMember extends Equatable {
  final String id;
  final String fullName;
  final String email;

  const HouseholdMember({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email];
}

/// Mirrors the backend's `HouseholdResponseDto`.
class Household extends Equatable {
  final String id;
  final String name;
  final HouseholdViewMode viewMode;
  final List<HouseholdMember> members;

  const Household({
    required this.id,
    required this.name,
    required this.viewMode,
    required this.members,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'] as String,
      name: json['name'] as String,
      viewMode: HouseholdViewMode.fromJson(json['viewMode'] as String),
      members: (json['members'] as List<dynamic>)
          .map((e) => HouseholdMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, viewMode, members];
}
