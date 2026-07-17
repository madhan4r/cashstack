/// Wire format for `POST /auth/register`.
class RegisterRequestDto {
  final String fullName;
  final String email;
  final String password;

  const RegisterRequestDto({
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
  };
}
