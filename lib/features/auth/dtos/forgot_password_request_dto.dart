/// Wire format for `POST /auth/forgot-password`.
class ForgotPasswordRequestDto {
  final String email;

  const ForgotPasswordRequestDto({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}
