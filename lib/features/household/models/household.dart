import 'package:equatable/equatable.dart';

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
  final List<HouseholdMember> members;

  const Household({required this.id, required this.name, required this.members});

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'] as String,
      name: json['name'] as String,
      members: (json['members'] as List<dynamic>)
          .map((e) => HouseholdMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, members];
}
