import 'package:equatable/equatable.dart';

/// The authenticated user, as used by the rest of the app (state, UI).
/// Constructed from [UserDto] — nothing outside `dtos/` and `services/`
/// should ever touch raw JSON for a user.
class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final bool isActive;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, fullName, email, isActive];
}
