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

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.preferredCurrency,
  });

  User copyWith({String? fullName, String? preferredCurrency}) {
    return User(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      isActive: isActive,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, isActive, preferredCurrency];
}
