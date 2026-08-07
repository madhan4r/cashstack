import 'package:equatable/equatable.dart';

/// The authenticated user, as used by the rest of the app (state, UI).
/// Constructed from [UserDto] — nothing outside `dtos/` and `services/`
/// should ever touch raw JSON for a user.
class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final bool isActive;
  final String preferredCurrency;

  /// Relative path (e.g. `/uploads/avatars/...`), not an absolute URL —
  /// see [AppConfig.apiOrigin]. `null` until the user uploads one.
  final String? avatarUrl;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.preferredCurrency,
    this.avatarUrl,
  });

  User copyWith({
    String? fullName,
    String? preferredCurrency,
    String? avatarUrl,
    bool clearAvatarUrl = false,
  }) {
    return User(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      isActive: isActive,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    isActive,
    preferredCurrency,
    avatarUrl,
  ];
}
