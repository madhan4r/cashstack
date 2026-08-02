import '../models/user.dart';

/// Wire format for the user object embedded in `AuthResponseDto` and
/// returned by `GET /users/me` — mirrors the backend's `UserResponseDto`
/// field-for-field. Kept separate from [User] (the domain model) so a
/// backend field rename only ever touches this file.
class UserDto {
  final String id;
  final String fullName;
  final String email;
  final bool isActive;
  final String preferredCurrency;

  const UserDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.preferredCurrency,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      isActive: json['isActive'] as bool? ?? true,
      preferredCurrency: json['preferredCurrency'] as String? ?? 'INR',
    );
  }

  User toDomain() {
    return User(
      id: id,
      fullName: fullName,
      email: email,
      isActive: isActive,
      preferredCurrency: preferredCurrency,
    );
  }
}
