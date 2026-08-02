import 'package:equatable/equatable.dart';

enum HouseholdInviteStatus { pending, accepted, declined, cancelled;

  factory HouseholdInviteStatus.fromJson(String value) {
    return switch (value) {
      'PENDING' => HouseholdInviteStatus.pending,
      'ACCEPTED' => HouseholdInviteStatus.accepted,
      'DECLINED' => HouseholdInviteStatus.declined,
      _ => HouseholdInviteStatus.cancelled,
    };
  }
}

/// Mirrors the backend's `HouseholdInviteResponseDto`.
class HouseholdInvite extends Equatable {
  final String id;
  final String householdId;
  final String householdName;
  final String invitedEmail;
  final String invitedByName;
  final HouseholdInviteStatus status;
  final DateTime createdAt;

  const HouseholdInvite({
    required this.id,
    required this.householdId,
    required this.householdName,
    required this.invitedEmail,
    required this.invitedByName,
    required this.status,
    required this.createdAt,
  });

  factory HouseholdInvite.fromJson(Map<String, dynamic> json) {
    return HouseholdInvite(
      id: json['id'] as String,
      householdId: json['householdId'] as String,
      householdName: json['householdName'] as String,
      invitedEmail: json['invitedEmail'] as String,
      invitedByName: json['invitedByName'] as String,
      status: HouseholdInviteStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    householdId,
    householdName,
    invitedEmail,
    invitedByName,
    status,
    createdAt,
  ];
}
